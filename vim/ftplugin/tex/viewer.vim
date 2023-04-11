" ============================================================================
" 	     File: texviewer.vim
"      Author: Mikolaj Machowski
"     Created: Sun Jan 26 06:00 PM 2003
" Description: make a viewer for various purposes: \cite{, \ref{
"     License: Vim Charityware License
"              Part of vim-latexSuite: http://vim-latex.sourceforge.net
" ============================================================================

if exists("b:tex_refcite_completion")
	finish
endif
let b:tex_refcite_completion = 1

if !exists('g:Tex_ViewerCwindowHeight')
	let g:Tex_ViewerCwindowHeight = 5
endif
if !exists('g:Tex_ViewerPreviewHeight')
	let g:Tex_ViewerPreviewHeight = 10 
endif
if !exists('g:Tex_ExplorerHeight')
	let g:Tex_ExplorerHeight = 10
endif


inoremap <silent> <F9> <Esc>:call Tex_rc_completion()<CR>

if getcwd() != expand("%:p:h")
	let s:search_dir =fnameescape(expand("%:h") . '/')
else
	let s:search_dir = ''
endif

"let b:grepprg = &grepprg
"if b:grepprg =~ 'internal'
"	let b:grepprg_op = 'j'
"else
"	let b:grepprg_op = ''
"endif

" Tex_rc_completion: main function {{{
" Description:
"
function! Tex_rc_completion()

	" Get info about current window and position of cursor in file
	let s:winnum = winnr()
	let s:pos = line('.').' | normal! '.virtcol('.').'|'
	call setqflist([])

	" What to do after <F9> depending on context
	let s:curfile = expand("%:p")
	let s:curline = strpart(getline('.'), col('.') - 40, 40)
	let s:prefix = matchstr(s:curline, '.*\({\|,\s*\)\zs.\{-}$')
	let s:type = matchstr(s:curline, '.*\\\zs.\{-}\ze{.\{-}$')
	let s:typeoption = matchstr(s:type, '\zs[.*]\ze')
	let s:type = substitute(s:type, '[.*', '', 'e')
	let ignorecase_old = &ignorecase
	let &ignorecase = 0
	if exists("s:type") && s:type =~ 'ref'
		"exec 'silent! grep! "\\label{'.s:prefix.'"'.b:grepprg_op.' '.s:search_dir.'*.tex'
		exec 'silent! vimgrep! "\\label{'.s:prefix.'"j '.s:search_dir.'*.tex'
	elseif exists("s:type") && s:type =~ 'cite'
		let bibfiles = <SID>Tex_FindBibFiles()
		let bblfiles = <SID>Tex_FindBblFiles()
		if bibfiles != ''
			"exe 'silent! grepadd! "@.*{'.s:prefix.'"'.b:grepprg_op.' '.bibfiles
			exe 'silent! vimgrepadd! "@.*{'.s:prefix.'"j '.bibfiles
		endif
		if bblfiles != ''
			"exe 'silent! grepadd! "bibitem{'.s:prefix.'"'.b:grepprg_op.' '.bblfiles
			exe 'silent! vimgrepadd! "bibitem{'.s:prefix.'"j '.bblfiles
		endif
	endif
	let &ignorecase = ignorecase_old
	if empty(getqflist())
		exe s:pos
		return
	else
		call <SID>Tex_c_window_setup()
	endif
endfunction " }}}

" Tex_c_window_setup: set maps and local settings for cwindow {{{
" Description: Set local maps jk<PageUp><PageDown>q<cr> for cwindow. 
" Also size and basic settings
"
function! s:Tex_c_window_setup()
	cclose
	exe 'copen '. g:Tex_ViewerCwindowHeight
	setlocal nonumber
	setlocal nowrap
	call <SID>SynctexUpdateWindow("i","")
    nnoremap <buffer> <silent> j j:call <SID>SynctexUpdateWindow("a","j")<CR>
    nnoremap <buffer> <silent> k k:call <SID>SynctexUpdateWindow("a","k")<CR>
    nnoremap <buffer> <silent> <up> <up>:call <SID>SynctexUpdateWindow("a","k")<CR>
    nnoremap <buffer> <silent> <down> <down>:call <SID>SynctexUpdateWindow("a","j")<CR>

	" Change behaviour of <cr> for 'ref' and 'cite' context. 
	if exists("s:type") && s:type =~ 'ref'
		nnoremap <buffer> <silent> <cr> :silent! call <SID>CompleteName("ref")<CR>
	elseif exists("s:type") && s:type =~ 'cite'
		nnoremap <buffer> <silent> <cr> :silent! call <SID>CompleteName("cite")<CR>
	endif

	exe 'nnoremap <buffer> <silent> q :call Tex_CloseSmallWindows()<cr>'

endfunction " }}}
" Tex_CloseSmallWindows: {{{
" Description:
"
function! Tex_CloseSmallWindows()
	exe s:winnum.' wincmd w'
	pclose!
	cclose
	exe s:pos
endfunction " }}}
"
" UpdateViewerWindow: update error and preview window {{{
" Description: Usually quickfix engine takes care about most of these things
" but we discard it for better control of events.
"
function! s:SynctexUpdateWindow(mode,move)

	"let viewfile = matchstr(getline('.'), '^\f*\ze|\d')
	"let viewline = matchstr(getline('.'), '|\zs\d\+\ze\(\s\+col\s\+\d\+\)\=|')
	let viewpos = matchlist(getline('.'), '\(^\f*\)|\(\d\+\)\(\s\+col\s\+\d\+\)\=|')
	if empty(viewpos)
		return
	endif
	let viewfile = viewpos[1]
	let viewline = viewpos[2]

	syntax clear
	runtime syntax/qf.vim
	exe 'syn match vTodo /\%'. line('.') .'l.*/'
	hi link vTodo Todo

	if a:mode == "i"
		exe 'silent! bot pedit +'.viewline.' '.viewfile
		"exe 'silent! bot pedit +set\ nofen '.viewfile
		"wincmd j
		"exe ":cc1"
		"wincmd k
	elseif a:mode == "a"
		wincmd j
		if a:move == 'j'
			cnext
		elseif a:move == 'k'
			cprev
		endif
		wincmd k
	endif

	" Vanilla 6.1 has bug. This additional setting of cwindow height prevents
	" resizing of this window
	exe g:Tex_ViewerCwindowHeight.' wincmd _'
	
	" Handle situation if there is no item beginning with s:prefix.
	" Unfortunately, because we know it late we have to close everything and
	" return as in complete process 
	if v:errmsg =~ 'E32\>'
		exe s:winnum.' wincmd w'
		pclose!
		cclose
		if exists("s:prefix")
			echomsg 'No bibkey, label or word beginning with "'.s:prefix.'"'
		endif
		if col('.') == strlen(getline('.'))
			startinsert!
		else
			normal! l
			startinsert
		endif
		let v:errmsg = ''
		return 0
	endif

	" Move to preview window. Really is it under cwindow?
	wincmd j

	" Settings of preview window
	exe g:Tex_ViewerPreviewHeight.' wincmd _'
	setlocal foldlevel=10

	if s:type =~ 'cite\|ref'
		" In cite context place bibkey at the top of preview window.
		setlocal scrolloff=0
		normal! zt
	endif

	" Return to cwindow
	wincmd p

endfunction " }}}
" CompleteName: complete/insert name for current item {{{
" Description: handle completion of items depending on current context
"
function! s:CompleteName(type)

	if a:type =~ 'cite'
		if getline('.') =~ '\\bibitem{'
			let bibkey = matchstr(getline('.'), '\\bibitem{\zs.\{-}\ze}')
		else
			let bibkey = matchstr(getline('.'), '{\zs.\{-}\ze,')
		endif
		let completeword = strpart(bibkey, strlen(s:prefix))
	elseif a:type =~ 'ref'
		let label = matchstr(getline('.'), '\\label{\zs.\{-}\ze}')
		let completeword = strpart(label, strlen(s:prefix))
	endif

	" Return to proper place in main window, close small windows
	if s:type =~ 'cite\|ref' 
		exe s:winnum.' wincmd w'
		pclose!
		cclose
	endif

	exe s:pos

	" Complete word, 
	exe 'normal! a'.completeword."\<Esc>"
	"check if add closing }
"	if getline('.')[col('.')-1] !~ '{' && getline('.')[col('.')] !~ '}'
"		exe "normal! a}\<Esc>"
"	endif

	" Return to Insert mode
	if col('.') == strlen(getline('.'))
		startinsert!

	else
		normal! l
		startinsert

	endif

endfunction " }}}
" GoToLocation: Go to chosen location {{{
" Description: Get number of current line and go to this number
"
function! s:GoToLocation()

	exe 'cc ' . line('.')
	pclose!
	cclose

endfunction " }}}

" Tex_FindBibFiles: find *.bib files {{{
" Description: scan files looking for \bibliography entries 
"
function! s:Tex_FindBibFiles()

		let bibfiles = ''
		let bibfiles2 = ''
		"let curdir = expand("%:p:h")
		"let curdir = substitute(curdir, ' ', "\\", 'ge')
		let curdir = fnameescape(expand("%:p:h"))
		let mainfdir = curdir

		if search('\\bibliography\s*{', 'w')
			let bibfiles2 = matchstr(getline('.'), '\\bibliography{\zs.\{-}\ze}')
			let bibfiles2 = substitute(bibfiles2, '\\string', '', 'g')
			let bibfiles2 = substitute(bibfiles2, '\(,\|$\)', '.bib ', 'ge')
		else
			let bibfiles2 = glob(mainfdir.'/*.bib')
			let bibfiles2 = substitute(bibfiles2, '\n', ' ', 'ge')
		endif
		"wincmd q

		return bibfiles2 
endfunction " }}}
" Tex_FindBblFiles: find bibitem entries in tex files {{{
" Description: scan files looking for \bibitem entries 
"
function! s:Tex_FindBblFiles()
		let bblfiles = ''
		let curdir = fnameescape(expand("%:p:h"))

		let bblfiles = glob(curdir.'/*.tex')
		let bblfiles = substitute(bblfiles, '\n', ' ', 'ge')

		return bblfiles
endfunction " }}}

" vim:fdm=marker:noet:ff=unix:ts=2:sw=2
