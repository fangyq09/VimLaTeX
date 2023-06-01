"=============================================================================
" 	     File: compile.vim
"      Author: Yangqin Fang
"       Email: fangyq09@gmail.com
" 	  Version: 1.1 
"     Created: 07/04/2013
" 
"  Description: A compile plugin for LaTeX
"  In normal mode, press <F2> to run pdflatex or xelatex, auto detect TeX
"  engine; press <S-F2> to run pdflatex; press <F6> to run xelatex;
"  press <F8> to compile bibtex. If you split you project into many separated
"  tex files, for example chapter1.tex, chapter2.tex, ..., in any chapter, you
"  press the shortcuts, it's all feasible.
"=============================================================================
if exists('b:loaded_vimtextric_compile')
	finish
endif
let b:loaded_vimtextric_compile = 1

if !exists('g:vimtextric_view_pdf')
	let b:vimtextric_view_pdf = 1
else 
	let b:vimtextric_view_pdf = g:vimtextric_view_pdf
endif


"if !exists('g:tex_flavor')
"	let b:tex_flavor = 'latexmk'
"else
"	let b:tex_flavor = g:tex_flavor
"endif
"exec "compiler ".b:tex_flavor
let &efm = '%-P**%f,%-P**"%f",%E! LaTeX %trror: %m,%E%f:%l: %m,'
			\ . '%E! %m,%Z<argument> %m,%Cl.%l %m,%-G%.%#'

function! TeX_Outils_Vimgrep(filename,pattern) "{{{1
	let fns = []
	let result = []
	call setqflist([]) " clear quickfix
	exec 'silent! vimgrep! ?'.a:pattern.'?j '.a:filename
	for i in getqflist()
		call add(fns,bufname(i.bufnr))
	endfor 
	"for fn in fns
	"	if fn != ''
	"		let fn_s = fnameescape(fnamemodify(fn,":p:t"))
	"		call add(result, fn_s)
	"	endif
	"endfor
	return fns
endfunction
"}}}

function! s:TeX_Outils_GetCommonItems(list1,list2) "{{{1
	let result = []
	for item in a:list1
		if count(a:list2,item) >0
			call add(result,item)
		endif
	endfor
	return result
endfunction
"}}}

function! s:Get_Main_TeX_File_Name() "{{{
	let cur_dir = expand('%:p:h')
	let projdirpath = fnameescape(cur_dir)
	let cur_file_name = expand('%:p')
	let par_dir = expand('%:p:h:h')
	let file_name_keep = substitute(cur_file_name,'^'.par_dir.'/','','')
	"exe 'lcd '.projdirpath
	let OrBuNa=fnameescape(expand('%:p:t'))
	let mtf1 = TeX_Outils_Vimgrep(projdirpath.'/*.tex','^\s*\\documentclass')
	let mtf2 = TeX_Outils_Vimgrep(projdirpath.'/*.tex','^\s*\\input{\s*'.OrBuNa.'\s*}')
	let mtf3 = s:TeX_Outils_GetCommonItems(mtf1,mtf2)
	if len(mtf3)==1
		call add(mtf3,cur_dir)
		return mtf3
	elseif len(mtf3)>1
		let output = map(copy(mtf3),'fnamemodify(v:val, ":t")')
		let num_output = []
		for ii in range(len(output))
			call add(num_output,string(ii+1).'.'.output[ii])
		endfor
		call inputsave()
		let file_choose = inputdialog("Please chose main tex file [".join(num_output,'; ')."]: ",1,0)
		call inputrestore()
		if (file_choose < 1) || (file_choose > len(output_new))
			return ['','']
		else
			let file_name = mtf3[file_choose-1]
			return [file_name, cur_dir]
		endif
	elseif len(mtf3)==0
		let dir_path = fnameescape(par_dir)
		let stfn = fnameescape(file_name_keep)
		let mtf4 = TeX_Outils_Vimgrep(dir_path.'/*.tex','^\s*\\documentclass')
		let mtf5 = TeX_Outils_Vimgrep(dir_path.'/*.tex','^\s*\\input{\s*\(\./\)\='.stfn.'\s*}')
		let mtf6 = s:TeX_Outils_GetCommonItems(mtf4,mtf5)
		if len(mtf6) == 1
			call add(mtf6,par_dir)
			return mtf6
		elseif len(mtf6) >1
			let output_new = map(copy(mtf6),'fnamemodify(v:val, ":t")')
			let num_output_new = []
			for ii in range(len(output_new))
				call add(num_output_new,string(ii+1).'.'.output_new[ii])
			endfor
			"call inputsave()
			let file_choose_new = inputdialog("Please choose main tex file No. [".join(num_output_new,'; ')."]: ",1,0)
			"call inputrestore()
			if (file_choose_new < 1) || (file_choose_new > len(output_new))
				return ['','']
			else
				let file_name_new = mtf6[file_choose_new -1]
				return [file_name_new,par_dir]
			endif
		else
			return ['','']
		endif
	endif
endfunction
"}}}

function! Find_Main_TeX_File() "{{{
	if exists('b:doc_class_line')  && (b:doc_class_line > 0)
		let main_tex_file = expand('%:p')
		let main_tex_dir = expand('%:p:h')
		let main_tex = [main_tex_file,main_tex_dir]
	elseif search('^\s*\\documentclass','bcwn')
		let main_tex_file = expand('%:p')
		let main_tex_dir = expand('%:p:h')
		let main_tex = [main_tex_file,main_tex_dir]
	else
		let main_tex = s:Get_Main_TeX_File_Name()
	endif
	return main_tex
endfunction
"}}}

"ViewPDF{{{
function! s:SumatraSynctexForward(file)
	lcd expand(%:p:h)
	silent execute "!start SumatraPDF -reuse-instance ".a:file." -forward-search \"".expand("%:p")."\" ".line(".")
endfunction

function! s:ZathuraSynctexForward(file)
  let source = expand("%:p")
  let input = shellescape(line(".").":".col(".").":".source)
  "let execstr = 'zathura -x "gvim --servername '.v:servername.' --remote-silent +\%{line} \%{input}" --synctex-forward='.input.' '.a:file.' &'
  let execstr = 'zathura -x "gvim --servername '.v:servername.' --remote-silent +exec\%{line} \%{input}" --synctex-forward='.input.' '.a:file.' &'
  silent call system(execstr)
endfunction

function! s:TeXViewPDF(file)
	if has("unix")
		call <SID>ZathuraSynctexForward(a:file)
	elseif has('win32') || has ('win64')
		call <SID>SumatraSynctexForward(a:file)
	endif
endfunction
"}}}

function! s:TeXCompileCloseHandler(channel) "{{{CloseHandler
	if empty(b:tex_compile_errors)
		cclose
		echo "successfully compiled"
		if b:vimtextric_view_pdf 
			silent! call <SID>TeXViewPDF(fnameescape(b:tex_pdf_name))
		endif
	else 
		"let log_content = b:tex_compile_log
		"let b:tex_compile_log = []
		let engine = b:tex_engine
		let log_content = readfile(b:tex_log_name)
		call setqflist([], ' ', {'title' : engine})
		let qfid = getqflist({'id' : 0}).id
		silent! call setqflist([], 'a', {'id': qfid, 'lines': log_content,
					\ 'efm': &efm})
		copen 5      " open quickfix window
		wincmd p    " jump back to previous window
		echohl WarningMsg
		echomsg "compile failed with errors"
		echohl None
	endif
endfunction
"}}}

function! s:TeXCompileOutHandler(job_id, msg) "{{{OutHandler
	if a:msg =~ '^\(.\{-}\.\(tex\|sty\):\d\+\|! LaTeX Error\):.*'
		call add(b:tex_compile_errors, a:msg)
	endif
endfunction
"}}}

function! s:TeXCancelJob() "{{{
	if exists('b:run_tex_job')
		let status = job_status(b:run_tex_job)
	else
		return ''
	endif
	if status == 'run'
		call job_stop(b:run_tex_job)
	endif
	return ''
endfunction
"}}}

"{{{ RunLaTeX_job(file,engine) 
"let b:tex_proj_dir = expand('%:p:h')
let b:tex_engine_options = '-synctex=1 -file-line-error -interaction=nonstopmode'
let b:tex_job_options = {
			\ 'out_io': 'pipe',
			\ 'out_cb': function('s:TeXCompileOutHandler'),
			\ 'close_cb': function('s:TeXCompileCloseHandler'),
			\ }
function! RunLaTeX_job(file,engine)
	"exec 'lcd ' . fnameescape(b:tex_proj_dir)
	let b:tex_compile_errors = [] 
	"let b:tex_compile_log = [] 
	"let tex_dir = expand('%:p:h')    " current dir
	"let tex_file = expand('%:p:t')    " current file
	"let b:tex_pdf_name = expand('%:p:r') .. '.pdf'    " current pdf
	if has('unix')
		let tex_cmd = 'cd ' . fnameescape(b:tex_proj_dir) . ' && ' . a:engine . ' '
					\ . b:tex_engine_options. ' ' . a:file
		let cmd = ['/bin/sh', '-c', tex_cmd]
	elseif has('win32') || has('win64')
		let tex_cmd = 'cd /d ' . fnameescape(b:tex_proj_dir) . ' && ' . a:engine . ' '
					\ . b:tex_engine_options. ' ' . a:file
		let cmd = &shell . ' /c ' . tex_cmd
	endif
	call setqflist([])
	let b:run_tex_job = job_start(cmd, b:tex_job_options)
	"call timer_start(120000,function('s:TeXCheckJobStatus'))
endfunction
"}}}

""{{{ RunLaTeX(file,engine)
function! RunLaTeX(file,engine)
	let dir_old = getcwd()
	exec 'lcd ' . b:tex_proj_dir
	silent setlocal shellpipe=>
	call setqflist([]) " clear quickfix
	let makeprg_old = &makeprg
	let &makeprg = a:engine.' '.b:tex_engine_options.' --shell-escape '.a:file
	silent make!  
	let &makeprg = makeprg_old
	lcd dir_old
	if v:shell_error
		let l:entries = getqflist()
		if len(l:entries) > 0 
			copen 5      " open quickfix window
			wincmd p    " jump back to previous window
			"call cursor(l:entries[0]['lnum'], 0) " go to error line
		else
			echohl WarningMsg
			echo "compile failed with errors"
			echohl None
		endif
	else
		cclose
		echon "successfully compiled"
		if b:vimtextric_view_pdf
			silent! call <SID>TeXViewPDF(fnameescape(b:tex_pdf_name))
		endif
	endif
endfunction
"}}}

"{{{ call RunLaTeX with proper TeX engine
function! s:Compile_LaTeX_Run(engine,view) 
	silent write
	if &ft != 'tex'
		echomsg "calling RunLaTeX from a non-tex file"
		return ''
	endif
	if !exists('b:tex_main_file_name')  || !exists('b:tex_proj_dir') || (b:tex_main_file_name == '')
		let [b:tex_main_file_name,b:tex_proj_dir] = Find_Main_TeX_File()
	endif
	if b:tex_main_file_name == ''
		echohl WarningMsg
		echomsg "no main tex file be found!"
		echohl None
		return ''
	endif
	let b:tex_pdf_name = substitute(b:tex_main_file_name,"\.tex$",".pdf","")
	let b:tex_log_name = substitute(b:tex_main_file_name,"\.tex$",".log","")
	let save_cursor= [bufnr("%"),line("."),col("."),0]

	" find TeX engine
	if a:engine == 'auto'
		if !exists('b:tex_engine')
			" Get the TeX engine from the line % !TeX engine/grogram = pdflatex/xelatex
			let l:current_file = expand('%:p')
			let com_str = '^\c\s*%\+.\{-}\(!\)*\s*\(TeX\)*\s*\(engine\|program\)*\s*\(=\|:\)*\s*\(pdf\|xe\|lau\)*latex.*'
			if b:tex_main_file_name == l:current_file
				exe '1'
				if !exists('b:doc_class_line')
					let b:doc_class_line = search('\s*\\documentclass','cnW')
				endif
				let tex_engine_com_line = search(com_str,'c',b:doc_class_line)
				if tex_engine_com_line
					let line_text = getline(tex_engine_com_line)
				endif
			else
				let main_tex_file_text = readfile(b:tex_main_file_name)
				let line_num = 0
				let tex_engine_com_line = 0
				for item in main_tex_file_text
					let line_num = line_num + 1 
					if item =~ com_str
						let line_text = item 
						let tex_engine_com_line = line_num
						break
					endif
				endfor
			endif
			if tex_engine_com_line == 0
				let b:tex_engine = 'pdflatex'
			else
				let  tex_engine_pre = substitute(line_text,com_str,'\5','')
				let b:tex_engine = tolower(tex_engine_pre) . 'latex'
			endif
		endif
	else 
		let b:tex_engine = a:engine
	endif

	""compile latex 
	if a:view == 0
		let b:vimtextric_view_pdf = 0
	endif
	if v:version >= 801
		echomsg "compiling with ".b:tex_engine."..."
		silent! call RunLaTeX_job(fnameescape(b:tex_main_file_name),b:tex_engine)
	else
		echomsg "compiling with ".b:tex_engine."..."
		silent! call RunLaTeX(fnameescape(b:tex_main_file_name),b:tex_engine)
	endif
	call setpos('.', save_cursor)
endfunction
"}}}

"View Dvi, and Dvi to PDF{{{
""这种方法生成的PDF文件质量好也可以避免中文书签乱码
function! s:DviToPDF(file)
	exec "silent !xdvipdfmx ".a:file
endfunction
function! s:VDwY()
	exe "silent !start YAP.exe -1 -s " . line(".") . "\"%<.TEX\" \"%<.DVI\""  
endfunction
""}}}

"Compile BibTeX{{{1
function! s:CompileBibTeX()
	if !exists('b:tex_main_file_name')  || !exists('b:tex_proj_dir')
		let [b:tex_main_file_name,b:tex_proj_dir] = Find_Main_TeX_File()
	endif
	lcd fnameescape(b:tex_proj_dir)
	let l:tex_mfn = b:tex_main_file_name
	if !exists('b:tex_bib_engine')  || (b:tex_bib_engine == '')
		if search('\\addbibresource\s*{.\+}','cnw')
			let b:tex_bib_engine = 'biber'
		else
			let b:tex_bib_engine = 'bibtex'
		endif
	endif
	if l:tex_mfn != ''
		let l:tex_mfwoe = substitute(l:tex_mfn,"\.tex$","","")
	else
		echomsg "no main file be found"
		return
	endif
	 silent! exec '!'.b:tex_bib_engine.' '.fnameescape(l:tex_mfwoe)
endfunction
"}}}1
"
"Compile asy {{{
function! s:CompileAsy()
	if !exists('b:tex_main_file_name')  || !exists('b:tex_proj_dir')
		let [b:tex_main_file_name,b:tex_proj_dir] = Find_Main_TeX_File()
	endif
	lcd fnameescape(b:tex_proj_dir)
	let l:tex_mfn = b:tex_main_file_name
	if l:tex_mfn != ''
		let l:tex_mf_asy = substitute(l:tex_mfn,"\.tex$","-*.asy","")
	else
		echomsg "no main file be found"
		return
	endif
	 silent! exec '!asy '.fnameescape(l:tex_mf_asy)
endfunction
"}}}

nnoremap <silent> <buffer><F2>  :call <SID>Compile_LaTeX_Run('auto',1)<CR>
nnoremap <silent> <buffer><S-F2>  :call <SID>Compile_LaTeX_Run('pdflatex',1)<CR>
nnoremap <silent> <buffer><F6>  :call <SID>Compile_LaTeX_Run("xelatex",1)<CR> 
nnoremap <silent> <buffer><F8> :call <SID>CompileBibTeX()<CR>
nnoremap <silent> <buffer><C-c> : call <SID>TeXCancelJob()<CR>
"{{{ menu
	menu 8000.60.040 &LaTeX.&Compile.&DVI\ To\ PDF<tab> "<C-F6>  
				\ :call <SID>DviToPDF(expand("%:r").".dvi")<CR>
	menu 8000.60.050 &LaTeX.&Compile.&XeLaTeX<tab><F6> 
				\ :call <SID>Compile_LaTeX_Run("xelatex",1)<CR>
	menu 8000.60.060 &LaTeX.&Compile.&pdfLaTeX<tab><S-F2> 
				\ :call <SID>Compile_LaTeX_Run("pdflatex",1)<CR>
	menu 8000.60.070 &LaTeX.&Compile.&Compile\ BibTeX<tab><F8>		
				\ :call <SID>CompileBibTeX()<CR>
	menu 8000.60.080 &LaTeX.&Compile.&Compile\ Asy<tab> "<C-F8>		
				\ :call <SID>CompileAsy()<CR>

"}}}
"
" vim:fdm=marker:noet:ff=unix
