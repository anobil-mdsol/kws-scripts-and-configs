#! /usr/bin/env ruby-rvm-env 2.1

require 'pathname'

require_relative '../utility/lib/executor'
require_relative '../utility/lib/ruby_version'

class AllProjectPuller
  def call
    root_dir = "#{Dir.home}/Sites"
    all_directories = Pathname.glob("#{root_dir}/apps/*") +
      Pathname.glob("#{root_dir}/gems/*").reverse +
      Pathname.glob("#{root_dir}/configs") +
      Pathname.glob("#{root_dir}/utilities/*") +
      Pathname.glob("#{root_dir}/scripts")

    SmartDirFilter.new.call(all_directories).each do |d|
      fork do
        Dir.chdir(d) do
          ProjectPuller.new.call
        end
      end
    end

    Process.waitall
  end
end

module PAP
  ROOT = Pathname(Dir.home).join("Sites/pap")
end

class SmartDirFilter
  def call(dirs)
    if updated_in_last_60_minutes?
      dirs_with_errors(dirs)
    else
      dirs
    end
  end

  def updated_in_last_60_minutes?
    PAP::ROOT.mtime > Time.now - 60 * 60
  end

  def dirs_with_errors(dirs)
    dirs.select{|d| error_logs.include?(d.basename.to_s) }
  end

  def error_logs
    PAP::ROOT.children(false).map{|f| f.to_s.match("error") && f.to_s.sub('_error.log','')}.compact
  end
end

class ProjectPuller
  def call
    start_timer
    puts "#{Dir.pwd} => #{gemset}" if ENV["DEBUG"] == "1"
    clear_logs
    output_string = "#{dir.ljust(50, '_')} => "
    from_branch development_branch do
      ex('git pull')
      setup_app
    end
    output_string += (@executions.any?(&:error?) ? "Fail" : "Pass")
  rescue => e
    output_string += "Fail"
    log_error_with_backtrace(e.message, e.backtrace)
  ensure
    stop_timer
    output_string += " (time: #{timer}s)"
    puts output_string
  end

  def setup_app
    run_setup_script ||
      old_setup
  end

  def old_setup
    install_gems
    Dir.chdir(migration_dir) do
      migrate
    end
  end

  def install_gems
    if File.exist?("Gemfile")
      ex "rvm #{gemset} do bundle install"
    end
  end

  def run_setup_script
    ex "rvm #{gemset} do bin/setup" if File.exist?("bin/setup")
  end

  def migrate
    if ['../../db/schema.rb', 'db/schema.rb'].any?{|f| Dir.exist?(f)}
      ex "rvm #{gemset} do rake db:migrate db:test:prepare", ignore: "sec:"
    end
  end

  def gemset
    @gemset = RubyVersion.current
  end

  def migration_dir
    Dir.exist?('spec/dummy') ? 'spec/dummy' : '.'
  end

  def from_branch(branch, &block)
    original_branch = g_branchname
    stash_changes
    clear_branch
    ex "git co #{branch}" unless branch == original_branch
    yield
  ensure
    clear_branch
    ex "git co #{original_branch}" unless branch == original_branch
    unstash
  end

  def development_branch
    return @development_branch if @development_branch
    branches = ex "git branch --list {master,dev}" 
    @development_branch = %w[dev  master].detect{|b| branches.include?(b)}
  end

  def g_branchname
    %x{git rev-parse --abbrev-ref HEAD 2>/dev/null}.gsub(/\n/, '')
  end

  def stash_changes
    if !git_changes.empty?
      ex 'git stash clear; git stash'
    end
  end

  def unstash
    if !git_changes.empty?
      ex 'git stash pop'
    end
  end

  def git_changes
    @git_changes ||= ex "git st --porcelain --untracked-files=no | tr -d ' '"
  end

  def clear_branch
    ex 'git reset --hard'
    ex 'git co .'
  end

  def dir
    @dir ||= Dir.pwd
  end

  def ex(*args)
    execution = Executor.new(self, *args)
    executions << execution
    execution.call
  end

  def executions
    @executions ||= Array.new
  end

  def log(text)
    File.open(log_path, 'a') do |f|
      f.write "#{text}\n\n"
    end
  end

  def log_error(text)
    File.open(error_log_path, 'a') do |f|
      f.write "#{text}"
    end
  end

  def log_error_with_backtrace(message, trace)
    File.open(error_log_path, 'a') do |f|
      f.write "#{message}"
      f.write "#{trace}"
    end
  end

  def clear_logs
    ex "mkdir -p #{PAP::ROOT}"
    File.delete(log_path) if File.exist?(log_path)
    File.delete(error_log_path) if File.exist?(error_log_path)
  end

  def log_path
    "#{PAP::ROOT}/#{self}.log"
  end

  def error_log_path
    "#{PAP::ROOT}/#{self}_error.log"
  end

  def to_s
    dir.gsub(/.*\/(.*)/, '\1')
  end

  def start_timer
    @start_time = Time.now
  end

  def stop_timer
    @stop_time = Time.now
  end

  def timer
    @stop_time - @start_time
  end
end

AllProjectPuller.new.call
