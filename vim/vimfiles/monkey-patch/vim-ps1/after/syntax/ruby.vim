if exists('b:current_syntax')
    let s:current_syntax=b:current_syntax
    " Remove current syntax definition, as some syntax files (e.g. ps1.vim)
    " do nothing if b:current_syntax is defined.
    unlet b:current_syntax
  endif
syntax include @PS1 syntax/ps1.vim
syntax region ps1Code start=+<<-PS1+hs=s+3 end=+PS1+ containedin=rubyString contains=@PS1
