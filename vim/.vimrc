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
  
  " Syntax
    " Highlighting
    Plug 'pearofducks/ansible-vim'                       " syntax plugin for Ansible 2.0
    Plug 'PProvost/vim-ps1',
      \ { 'do': 'cp -r ~/.vim/monkey-patch/vim-ps1/ .' } " syntax coloring and indenting for Windows PowerShell
    Plug 'b4b4r07/vim-hcl'                               " syntax plugin for HCL
    Plug 'fatih/vim-go'                                  " syntax plugin for Go
    Plug 'hashivim/vim-terraform'                        " syntax plugin for Terraform
  
    " Formatting
    Plug 'tpope/tpope-vim-abolish'  " Support for Case Sensitive Replace
    Plug 'Chiel92/vim-autoformat'   " Code Auto Formatter
    let g:autoformat_autoindent = 0
    let g:autoformat_retab = 0
    let g:autoformat_remove_trailing_spaces = 0
    let g:terraform_fmt_on_save = 1 " Auto Format Terraform on Write
    au BufWrite * :Autoformat
    Plug 'https://gist.github.com/PeterRincker/582ea9be24a69e6dd8e237eb877b8978.git',
      \ { 'as': 'SortGroup', 'do': 'mkdir plugin; mv -f *.vim plugin/', 'on': 'SortGroup' } " Sort Multi Line Groups
    
    " Code Checkers
    Plug 'scrooloose/syntastic'                  " syntax checking
    Plug 'juliosueiras/vim-terraform-completion' " Auto Completion

  
  " Control Plugins
  Plug 'kien/ctrlp.vim'                                         " Fuzzy file, buffer, mru, tag, etc finder. 
  Plug 'tpope/vim-commentary'                                   " Comment stuff out.
  Plug 'Valloric/YouCompleteMe', { 'do': function('BuildYCM') } " fast, as-you-type, fuzzy-search code completion engin
  
  " Git Plugins
  Plug 'airblade/vim-gitgutter' "git diff in the 'gutter' (sign column)
  Plug 'tpope/vim-fugitive'     " View any blob, tree, commit, or tag in the repository
  
  " UI Plugins
  Plug 'itchyny/lightline.vim'            " light and configurable statusline/tabline 
  Plug 'altercation/vim-colors-solarized' " Solarized Colorscheme
call plug#end()

set number                     " Print the line number in front of each line.
set scrolloff=10                " Minimum number of screen lines above/below the cursor.
set ruler                      " Show the line and column number of the cursor position
set paste                      " Set Paste so that it does not retab
set showcmd                    " Show (partial) command in the last line of the screen.
set showmatch                  " When a bracket is inserted, briefly jump to the matching one.
set statusline+=%#warningmsg#  " switch to warningmsg color
set statusline+=%*             " back to normal color
set backspace=indent,eol,start " Allows backspace to delete over line breaks
set background=dark            " informs vim that the background color is dark

silent! colorscheme solarized

if exists(':SyntasticCheck') " Validate Syntastic is Functional
  let g:syntastic_ruby_checkers            = ['rubocop']
  let g:syntastic_ruby_rubocop_exec        = '/opt/chefdk/bin/rubocop'
  let g:syntastic_always_populate_loc_list = 1
  let g:syntastic_auto_loc_list            = 1
  let g:syntastic_check_on_open            = 1
  let g:syntastic_check_on_wq              = 0

  set statusline+=%{SyntasticStatuslineFlag()} " show Syntastic flag
endif

syntax enable " enables syntax highlighting
au BufReadPost Jenkinsfile set syntax=groovy " enables syntax for Jenkinsfile
au BufReadPost Jenkinsfile set filetype=groovy

if has('gui_running') " running inside of a GUI
  set guifont=Lucida_Console:h11:cANSI:qDRAFT " set font

  "Plugins for LightLine
  set laststatus=2 "display the status line always
  set noshowmode " hides insert status for supporting lightline
endif
