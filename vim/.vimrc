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
    Plug 'fatih/vim-go', { 'for': ['go'] }               " syntax plugin for Go
      let g:go_fmt_command = "goimports"
    Plug 'b4b4r07/vim-hcl', { 'for': ['hcl','terraform'] }           " syntax plugin for HCL
    Plug 'hashivim/vim-terraform', { 'for': ['hcl','terraform'] }    " syntax plugin for Terraform
      let g:terraform_fmt_on_save = 1 

    " Formatting
    Plug 'tpope/tpope-vim-abolish'    " Support for Case Sensitive Replace
    Plug 'Chiel92/vim-autoformat'     " Code Auto Formatter
      let g:autoformat_autoindent = 0
      let g:autoformat_retab = 0
      let g:autoformat_remove_trailing_spaces = 0
      let g:formatdef_ruby_cookstyle = "'/usr/local/bin/cookstyle --auto-correct --out /dev/null --stdin '.bufname('%').' \| sed -n 2,\\$p'"
      let g:formatters_ruby = ['ruby_cookstyle']
      au BufWrite * :Autoformat
    Plug 'https://gist.github.com/TechIsCool/0be56d68fbf9eb767e595b4c4df0508b.git',
      \ { 'as': 'SortGroup', 'do': 'mkdir plugin; mv -f *.vim plugin/', 'on': 'SortGroup' } " Sort Multi Line Groups
    
    " Code Checkers
    Plug 'scrooloose/syntastic'                    " syntax checking
      let g:syntastic_ruby_checkers            = ['rubocop']
      let g:syntastic_ruby_rubocop_exec        = '/usr/local/bin/cookstyle'
      let g:syntastic_python_checkers          = ['flake8']
      let g:syntastic_always_populate_loc_list = 1
      let g:syntastic_auto_loc_list            = 1
      let g:syntastic_check_on_open            = 1
      let g:syntastic_check_on_wq              = 0
      set statusline+=%{SyntasticStatuslineFlag()} " show Syntastic flag
    Plug 'https://gist.github.com/TechIsCool/0e080232d9e8871f9611a4e9a6f0ab91.git',
      \ { 'as': 'TerraformCompleteOpenDoc', 'do': 'mkdir plugin; mv -f *.vim plugin/', 'for': ['hcl','terraform']} " Terraform OpenDoc
      noremap <buffer><silent> <Leader>o :call terraformcomplete#OpenDoc()<CR>
  
  " Control Plugins
  Plug 'kien/ctrlp.vim'                                         " Fuzzy file, buffer, mru, tag, etc finder. 
  Plug 'tpope/vim-commentary'                                   " Comment stuff out.
  Plug 'Valloric/YouCompleteMe', { 'do': function('BuildYCM') } " fast, as-you-type, fuzzy-search code completion engin
      let g:enable_ycm_at_startup = 0
  
  " Git Plugins
  Plug 'airblade/vim-gitgutter', { 'commit': 'c92f61acdc1841292b539a8515a88ed811eafa3f' } " git diff in the 'gutter' (sign column)
      let g:gitgutter_max_signs = 10000
  Plug 'tpope/vim-fugitive'     " View any blob, tree, commit, or tag in the repository
  
  " UI Plugins
  Plug 'itchyny/lightline.vim'            " light and configurable statusline/tabline 
  Plug 'altercation/vim-colors-solarized' " Solarized Colorscheme

  " YAML Plugins
  Plug 'lmeijvogel/vim-yaml-helper' " provides getting a full path in yaml
    let g:vim_yaml_helper#always_get_root = 1
    au FileType yaml noremap <buffer> <silent> <leader>p :YamlDisplayFullPath<CR>
    au FileType yaml noremap <buffer> <silent> <leader>g :YamlGoToKey<CR>

  " JSON Plugins
  Plug 'mogelbrod/vim-jsonpath' " provides ways of navigating JSON document buffers.
    au FileType json noremap <buffer> <silent> <expr> <leader>p jsonpath#echo()
    au FileType json noremap <buffer> <silent> <expr> <leader>g jsonpath#goto()
call plug#end()

set number                     " Print the line number in front of each line.
set scrolloff=10               " Minimum number of screen lines above/below the cursor.
set ruler                      " Show the line and column number of the cursor position
set paste                      " Set Paste so that it does not retab
set showcmd                    " Show (partial) command in the last line of the screen.
set showmatch                  " When a bracket is inserted, briefly jump to the matching one.
set statusline+=%#warningmsg#  " switch to warningmsg color
set statusline+=%*             " back to normal color
set backspace=indent,eol,start " Allows backspace to delete over line breaks
set background=dark            " informs vim that the background color is dark

" Expansion
autocmd FileType sh iabbrev <buffer> shebang #!/bin/bash
autocmd FileType xml setlocal shiftwidth=2 softtabstop=2 expandtab

silent! colorscheme solarized

syntax enable " enables syntax highlighting

au BufReadPost Jenkinsfile set syntax=groovy " enables syntax for Jenkinsfile
au BufReadPost Jenkinsfile set filetype=groovy

if has('gui_running') " running inside of a GUI
  set guifont=Lucida_Console:h11:cANSI:qDRAFT " set font

  "Plugins for LightLine
  set laststatus=2 "display the status line always
  set noshowmode " hides insert status for supporting lightline
endif

function! PatchJira()
  %s/\`\`\`/{code}/g
  %s/\`/**/g
endfunction
