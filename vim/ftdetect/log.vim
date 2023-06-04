"for texlog.vim
au BufEnter *.log call FTTexlog()
function! FTTexlog()
  if getline(1) =~# '^This is \S*TeX[^,]*, Version .\+$'
    setfiletype latexlog
  else
    return
  endif
endfunction
