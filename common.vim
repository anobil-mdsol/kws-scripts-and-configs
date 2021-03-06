echo 'hi'
syntax enable
colorscheme google
set shell=/bin/sh
set t_Co=256
set nocompatible
set nowrap
set scrolloff=5
set autoindent
set smartindent
set numberwidth=6
"set foldcolumn=2
highlight Folded ctermbg=0 ctermfg=15
set tabstop=2                     " a tab is two spaces
set shiftwidth=2                  " an autoindent (with <<) is two spaces
set expandtab
set noignorecase
set smartcase
set backspace=indent,eol,start    " backspace through everything in insert mode
set laststatus=2
set wildmode=list:full,full       " tab completion in command line
set wildmenu
set splitbelow
set splitright

set backupdir=~/.vim/backup
"set directory=~/.vim/swap
set noswapfile

" fuzzy find
set rtp+=/usr/local/opt/fzf

let g:sqlutil_load_default_maps = 0

" get rid of esc delay
set timeoutlen=1000 ttimeoutlen=0

"function! FontSizeChange(size)
"  let basesize=12
"  if(a:size > basesize)
"    let totallines=&lines * basesize / a:size
"  else
"    let totallines=&lines * a:size / basesize
"  end
"
"  let &lines=totallines
"  exec 'set guifont=consolas:h' . a:size
"  set winheight=999
"  echo totallines
"endfunc

if &diff
  nmap <down>
  nmap <left> :diffget //2<cr>
  nmap <right> :diffget //3<cr>
  nmap <up> :only<cr>
end

nnoremap ; :

nnoremap y% :%y+<CR>

nnoremap \<c>' :s/'/"/g<cr>
nnoremap \<c>" :%s/'/"/g<cr>

nnoremap <enter> J

filetype plugin indent on

" RELATIVE LINE NUMBERING
" set relativenumber
set number

"au InsertEnter * :set norelativenumber
"au InsertLeave * :set relativenumber

"au BufLeave * :set norelativenumber
"au BufEnter * :set relativenumber
 
"function! KwsFunFocusLose()
  "if(empty(hasntNumber))
    ":set number
  "else
    ":set nonumber
  "endif
"endfunc

"function! KwsFunFocusGain()
  "if(mode() == 'i')
    ":set number
  "else
    ":set relativenumber
  "endif
"endfunc

function! KwsFunHello()
  :echo 'HELLO'
endfunc
 
au FocusLost * set norelativenumber
au FocusGained * set relativenumber
au FocusLost * call KwsFunHello()
" clear all buffers
nnoremap <leader><delete> :bufdo<space>bd<Cr>
nnoremap <leader><s-delete> :bufdo<space>bd<Cr>:q<Cr>
nnoremap <leader><backspace> :windo<space>bd<Cr>

" tabs
nnoremap J :tabprevious<cr>
nnoremap K :tabnext<cr>

" mush esc
call arpeggio#map('i','',0,'jk','<esc>')
call arpeggio#map('i','',0,'JK','<esc>')
call arpeggio#map('i','',0,'Jk','<esc>')
call arpeggio#map('i','',0,'Kj','<esc>')

"save file
nnoremap <S-s> :wa<Cr>
nnoremap <leader>d :!mkdir -p %:h<Cr>

"logging

autocmd BufWritePre * %s/\(\w\)\s\+$/\1/ge

au FileType eruby filetype indent off
au FileType eruby filetype indent on

"whitespace highlighting

hi ExtraWhitespace ctermbg=red guibg=red
autocmd Syntax * syn match ExtraWhitespace '\s\+$'

" long line highlighing

highlight LongLines ctermbg=18 guibg=#333300
au FileType ruby,javascript,coffee,vim call matchadd('LongLines', '^.\{80,107}$', -1)

highlight VeryLongLines ctermbg=52 guibg=#330000
au FileType ruby,javascript,coffee,vim call matchadd('VeryLongLines', '^.\{108,}$', -1)

" indent highlighting

"highlight OddIndent ctermbg=236 guibg=#303030
"highlight EvenIndent ctermbg=240 guibg=#585858

"au FileType * call matchadd('OddIndent', '\%(^\|\%(\s\s\)\)\zs\s\s\ze\s\s')
"au FileType * call matchadd('EvenIndent', '\(\s\s\)\zs\1\ze\1')

" STATUS LINE
:set statusline=%<%f\ (%{&ft})\ %-4(%m%)%=%-19(%3l,%02c%03V%)

" OPEN FILES IN DIRECTORY OF CURRENT FILE
cnoremap %% <C-R>=(expand('%:h')).'/'<cr>
map <leader>e :up<CR>:edit %%
map <leader>E :up<CR>:edit ./
map <leader>v :view %%
map <leader>V :view ./
map <leader>t :tabnew %%
map <leader>T :tabnew ./
map <leader>s :split %%
map <leader>S :split ./
map <leader>r :bufdo<space>e<cr>

" RENAME CURRENT FILE
function! RenameFile()
  let old_name = expand('%')
  let new_name = input('New file name: ', expand('%'), 'file')
  if new_name != '' && new_name != old_name
    exec ':saveas ' . new_name
    exec ':silent !rm ' . old_name
    redraw!
  endif
endfunction
map <leader>N :call RenameFile()<cr>

" GIT MOVE CURRENT FILE
function! GitMoveFile()
  let old_name = expand('%')
  let new_name = input('New file name: ', expand('%'), 'file')
  if new_name != '' && new_name != old_name
    exec ':Gmove ' . new_name
    redraw!
  endif
endfunction
map <leader>n :call GitMoveFile()<cr>

nnoremap <leader><leader> <c-^>

" word wrapping
nnoremap <leader>" "wciw""<esc><left>"wp
nnoremap <leader>' "wciw''<esc><left>"wp
nnoremap <leader>( "wciw()<esc><left>"wp
nnoremap <leader>{ "wciw{}<esc><left>"wp
nnoremap <leader>[ "wciw[]<esc><left>"wp

" tab manipulation
nnoremap <c-t>$ :$tabm<cr>
nnoremap <c-t>0 :0tabm<cr>
nnoremap <c-t>l :tabm+<cr>
nnoremap <c-t>h :tabm-<cr>

" shebang filetype detection

function! s:DetectFileType()
  if did_filetype()
    return
  endif
  if getline(1) =~ '^#!.*ruby'
    setfiletype ruby
  endif
endfunction
au BufNewFile,BufRead Guardfile,.Guardfile setfiletype ruby

au BufNewFile,BufRead * :call s:DetectFileType()

au BufEnter * :checktime

" rotate windows
nnoremap <c-w><end> :tabdo wincmd h \| wincmd K<cr>
nnoremap <c-w><home> :tabdo wincmd k \| wincmd H<cr>


let g:ale_lint_delay=500
let g:ale_set_signs=0

if file_readable('.rubocop.yml')
  let g:ale_fixers = {
        \   'ruby': [
        \       'ale#fixers#rubocop#Fix',
        \   ],
        \}

  let g:ale_ruby_rubocop_executable='be rubocop'
endif


call arpeggio#map('n','',0,'at',':ALEToggle<CR>')
call arpeggio#map('n','',0,'af',':ALEFix<CR>')


let g:ruby_indent_block_style = 'do'
let g:ruby_indent_access_modifier_style = 'indent'
let g:ruby_indent_assignment_style = 'variable'


function! ProseMode()
  set spell noci nosi noai nolist noshowmode noshowcmd wrap linebreak
  set complete+=s
  set bg=light
  nunmap J
  nunmap K
  if !has('gui_running')
    let g:solarized_termcolors=256
  endif
  colors solarized
endfunction

command! ProseMode call ProseMode()
nmap \p :Goyo<CR>
nmap ZZ :w<CR>:q<CR>:q<CR>
au User GoyoEnter nested call ProseMode()
au VimEnter PULLREQ_EDITMSG,*.txt Goyo
