"=============================================================================
" 	     File: compile.vim
"      Author: Yangqin Fang
"       Email: fangyq09@gmail.com
" 	  Version: 1.1 
"     Created: 07/04/2013
" 
"  Description: A compile plugin for LaTeX
"  In normal mode, press <F2> to run pdflatex, press <F6> to run xelatex,
"  press <F8> to compile bibtex. If you split you project into many separated
"  tex fils, for example chapter1.tex, chapter2.tex, ..., in any chapter, you
"  press the shortcuts, it's all feasible.
"=============================================================================
if exists('b:vimtextric_compile')
	finish
endif
let b:vimtextric_compile = 1

function! TeX_Outils_Vimgrep(filename,pattern) "{{{1
	let fns = []
	let result = []
	call setqflist([]) " clear quickfix
	exec 'silent! vimgrep! ?'.a:pattern.'?j '.a:filename
	for i in getqflist()
		call add(fns,bufname(i.bufnr))
	endfor 
	for fn in fns
		if fn != ''
			let fn_s = fnameescape(fnamemodify(fn,":p:t"))
			call add(result, fn_s)
		endif
	endfor
	return result
endfunction
"}}}

function! s:TeX_Outils_GetCommonItems(list1,list2) "{{{1
	let result = []
	for i in a:list1
		if count(a:list2,i) >0
			call add(result,i)
		endif
	endfor
	return result
endfunction
"}}}

function! Get_Main_TeX_File_Name() "{{{1
	let projdirpath = fnameescape(expand('%:p:h'))
	exe 'cd '.projdirpath
	let OrBuNa=fnameescape(expand('%:p:t'))
	let mtf1 = TeX_Outils_Vimgrep(projdirpath.'/*.tex','^\s*\\documentclass')
	let mtf2 = TeX_Outils_Vimgrep(projdirpath.'/*.tex','^\s*\\input{\s*'.OrBuNa.'\s*}')
	let mtf3 = s:TeX_Outils_GetCommonItems(mtf1,mtf2)
	if len(mtf3)==1
		return join(mtf3)
	elseif len(mtf3)==0
		return '' 
	elseif len(mtf3)>1
		let outputs = join(mtf3,';')
		return input("please chose main tex file [".outputs."]: ")
	endif
endfunction
"}}}

function! Find_Main_TeX_File() "{{{1
	if exists('b:doc_class_line')  && (b:doc_class_line > 0)
		let main_tex_file = fnameescape(expand('%:p:t'))
	elseif search('^\s*\\documentclass','bcwn')
		let main_tex_file = fnameescape(expand('%:p:t'))
	else
		let main_tex_file = Get_Main_TeX_File_Name()
	endif
	return main_tex_file
endfunction
"}}}

"ViewPDF{{{1
function! SumatraSynctexForward(file)
	lcd %:p:h
	silent execute "!start SumatraPDF -reuse-instance ".a:file." -forward-search \"".expand("%:p")."\" ".line(".")
endfunction

function! ZathuraSynctexForward(file)
  let source = expand("%:p")
  let input = shellescape(line(".").":".col(".").":".source)
  "let execstr = 'zathura -x "gvim --servername '.v:servername.' --remote-silent +\%{line} \%{input}" --synctex-forward='.input.' '.a:file.' &'
  let execstr = 'zathura -x "gvim --servername '.v:servername.' --remote-silent +exec\\ \%{line} \%{input}" --synctex-forward='.input.' '.a:file.' &'
  silent call system(execstr)
endfunction

function! TexViewPDF(file)
	if has("unix")
		call ZathuraSynctexForward(a:file)
	elseif has('win32') || has ('win64')
		call SumatraSynctexForward(a:file)
	endif
endfunction
"}}}

""{{{ RunLaTeX
function! TexCompileRun(engine,viewer)
	silent write
	if &ft == 'tex'
		let b:tex_flavor = 'latexmk'
	else
		echomsg "calling RunLaTeX from a non-tex file"
		return
	endif
	if !exists('b:tex_main_file_name')  || (b:tex_main_file_name == '')
		let b:tex_main_file_name = Find_Main_TeX_File()
	endif
	let l:tex_mfn = b:tex_main_file_name
	if l:tex_mfn == ''
		":redraw!
		echohl WarningMsg
		echomsg "no main tex file be found!"
		echohl None
		return
	endif

	if l:tex_mfn != ''
		let l:pdf_fn = substitute(l:tex_mfn,".tex$",".pdf","")
	endif


	let save_cursor= [bufnr("%"),line("."),col("."),0]
	silent setlocal shellpipe=>
	exe 'cd '.fnameescape(expand('%:p:h'))
	call setqflist([]) " clear quickfix
	exec "compiler ".b:tex_flavor
	echon "compiling with ".a:engine."..."
	let makeprg_old = &makeprg
	let &makeprg = a:engine.' -synctex=1 -file-line-error -interaction=nonstopmode '.l:tex_mfn
	silent make!  
	let &makeprg = makeprg_old
	if v:shell_error
		let l:runtex_error = 1
		let l:entries = getqflist()
		if len(l:entries) > 0 
			copen 5      " open quickfix window
			wincmd p    " jump back to previous window
			call cursor(l:entries[0]['lnum'], 0) " go to error line
		else
			echohl WarningMsg
			echomsg "compile failed with errors"
			echohl None
			call setpos('.', save_cursor)
		endif
	else
		let l:runtex_error = 0
		cclose
		call setpos('.', save_cursor)
		"redraw!
		echon "successfully compiled"
	endif
	if a:viewer>0 && l:runtex_error<1
		silent call TexViewPDF(l:pdf_fn)
	endif
endfunction
"}}}1

"View Dvi, and Dvi to PDF{{{1
""这种方法生成的PDF文件质量好也可以避免中文书签乱码
function! DviToPDF(file)
	exec "silent !xdvipdfmx ".a:file
endfunction

function! s:VDwY()
	exe "silent !start YAP.exe -1 -s " . line(".") . "\"%<.TEX\" \"%<.DVI\""  
endfunction
""}}}1

"Comile BibTeX{{{1
function! s:CompileBibTeX()
	exe 'lcd '.fnameescape(expand('%:p:h'))
	if !exists('b:tex_main_file_name')  || (b:tex_main_file_name == '')
		let b:tex_main_file_name = Find_Main_TeX_File()
	endif
	let l:tex_mfn = b:tex_main_file_name
	if !exists('b:tex_bib_engine')  || (b:tex_bib_engine == '')
		if search('\\addbibresource\s*{.\+}','cnw')
			let b:tex_bib_engine = 'biber'
		else
			let b:tex_bib_engine = 'bibtex'
		endif
	endif
	if l:tex_mfn != ''
		let l:tex_mfwoe = substitute(l:tex_mfn,".tex$","","")
	else
		echomsg "no main file be found"
		return
	endif
	 silent! exec '!'.b:tex_bib_engine.' '.l:tex_mfwoe
endfunction
"}}}1

nnoremap <silent> <buffer><F2>  :call TexCompileRun("pdflatex",1)<CR>
nnoremap <silent> <buffer><F6>  :call TexCompileRun("xelatex",1)<CR> 
nnoremap <silent> <buffer><F8> :call <SID>CompileBibTeX()<CR>
"{{{1
	menu 8000.60.040 &LaTeX.&Compile.&DVI\ To\ PDF<tab><C-F6>  
				\ :call DviToPDF(expand("%:r").".dvi")<CR>
	menu 8000.60.050 &LaTeX.&Compile.&XeLaTeX<tab><F6> 
				\ :call TexCompileRun("xelatex",1)<CR>
	menu 8000.60.060 &LaTeX.&Compile.&pdfLaTeX<tab><F2> 
				\ :call TexCompileRun("pdflatex",1)<CR>
	menu 8000.60.070 &LaTeX.&Compile.&Compile\ BibTeX<tab><F8>		
				\ :call <SID>CompileBibTeX()<CR>

"}}}
"
" vim:fdm=marker:noet:ff=unix
