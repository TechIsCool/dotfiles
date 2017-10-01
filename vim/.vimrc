call plug#begin('~/.vim/plugged')

function! BuildYCM(info)
  " info is a dictionary with 3 fields
  " - name:   name of the plugin
  " - status: 'installed', 'updated', or 'unchanged'
  " - force:  set on PlugInstall! or PlugUpdate!
  if a:info.status == 'installed' || a:info.force
    !./install.py
  endif
endfunction

" Syntax Plugins
" syntax plugin for Ansible 2.0
Plug 'pearofducks/ansible-vim'
" syntax coloring and indenting for Windows PowerShell
Plug 'PProvost/vim-ps1'
" syntax plugin for HCL
Plug 'b4b4r07/vim-hcl'
" syntax plugin for Go
Plug 'fatih/vim-go'
" syntax plugin for Terraform
Plug 'hashivim/vim-terraform'

" Code Auto Formatter
Plug 'Chiel92/vim-autoformat'
let g:autoformat_autoindent = 0
let g:autoformat_retab = 0
let g:autoformat_remove_trailing_spaces = 0

" Support for Case Sensitive Replace
Plug 'tpope/tpope-vim-abolish'

"Auto Formatting on Write
let g:terraform_fmt_on_save = 1
au BufWrite * :Autoformat

" Code Checkers
Plug 'scrooloose/syntastic'
if exists(":SyntasticCheck")
  let g:syntastic_ruby_checkers            = ['rubocop']
  let g:syntastic_ruby_rubocop_exec        = '/opt/chefdk/bin/rubocop'
  let g:syntastic_always_populate_loc_list = 1
  let g:syntastic_auto_loc_list            = 1
  let g:syntastic_check_on_open            = 1
  let g:syntastic_check_on_wq              = 0

  " show Syntastic flag
  set statusline+=%{SyntasticStatuslineFlag()}
endif

" Auto Completion
Plug 'juliosueiras/vim-terraform-completion'

" Control Plugins
Plug 'kien/ctrlp.vim'
" Comment stuff out.
Plug 'tpope/vim-commentary'
" fast, as-you-type, fuzzy-search code completion engin
Plug 'Valloric/YouCompleteMe'

" Git Plugins
"git diff in the 'gutter' (sign column).
Plug 'airblade/vim-gitgutter'
" View any blob, tree, commit, or tag in the repository
Plug 'tpope/vim-fugitive'

" UI Plugins
" light and configurable statusline/tabline
 Plug 'itchyny/lightline.vim'

" Solarized Colorscheme
Plug 'altercation/vim-colors-solarized'
call plug#end()

" Print the line number in front of each line.
set number
" Show the line and column number of the cursor position
set ruler
" Set Paste so that it does not retab
set paste
" Show (partial) command in the last line of the screen.
set showcmd
" When a bracket is inserted, briefly jump to the matching one.
set showmatch
" switch to warningmsg color
set statusline+=%#warningmsg#
" back to normal color
set statusline+=%*
" Allows backspace to delete over line breaks
set backspace=indent,eol,start
" informs vim that the background color is dark
set background=dark

" enables syntax highlighting
syntax enable
" enables syntax for Jenkinsfile
au BufReadPost Jenkinsfile set syntax=groovy
au BufReadPost Jenkinsfile set filetype=groovy

silent! colorscheme solarized

if has('gui_running')
  " running inside of a GUI
  " set font
  set guifont=Lucida_Console:h11:cANSI:qDRAFT

  "Plugins for LightLine
  "display the status line always
  set laststatus=2
  " hides insert status for supporting lightline
  set noshowmode
endif
