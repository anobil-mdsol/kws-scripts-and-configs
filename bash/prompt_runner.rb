require 'term/ansicolor'

include Term::ANSIColor

def rbv
  RUBY_VERSION
end

def rubytxt
  if !%{ which rvm }.empty?
    gemset = %x{ rvm gemset name 2>/dev/null }.gsub(/\n/, '')
    if Dir.pwd.match(/(?!\/)#{gemset}$/)
      green(rbv)
    elsif gemset.match(/\//)
      rbv
    else
      red(rbv)
    end
  else
    rbv
  end
end

def railstxt
  env = ENV["RAILS_ENV"]
  if env
    ")(RENV = #{env}"
  end
end

def gitbranch
  g = g_working_directory + g_branchname

  if g_ahead && g_behind
    red(g)
  elsif g_ahead
    yellow(g)
  elsif g_behind
    green(g)
  else
    g
  end
end

def g_branchname
  @branch ||= %x{git rev-parse --abbrev-ref HEAD 2>/dev/null}.gsub(/\n/, '')
end

def g_ahead
  g_st.match(/ahead.*of.*commit/)
end

def g_behind
  g_st.match(/behind.*by.*commit/)
end

def g_working_directory
  if g_clean
    ""
  else
    "+ "
  end
end

def g_clean
  g_st.match(/nothing.to.commit,.working.directory.clean/)
end

def g_st
  @status ||= %x{ git status 2>/dev/null }
end

def gittxt
  gb = gitbranch
  if gb
    ")(#{gb}"
  end
end

puts "\n#{Dir.pwd}  (#{rubytxt}#{railstxt}#{gittxt})  #{Time.now.strftime("%b %e")}\n>> "
