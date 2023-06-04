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
	"exec 'lcd ' . expand(%:p:h)
	"silent execute "!start SumatraPDF -reuse-instance ".a:file." -forward-search \"".expand("%:p")."\" ".line(".")
	silent execute '!start SumatraPDF -reuse-instance '.a:file.' -forward-search "'.b:tmp_source.'" '.b:tmp_cursor[0]
endfunction

function! s:ZathuraSynctexForward(file)
  "let source = expand("%:p")
  "let input = shellescape(line(".").":".col(".").":".source)
	let input = shellescape(b:tmp_cursor[0].":".b:tmp_cursor[0].":".b:tmp_source)
  "let execstr = 'zathura -x "gvim --servername '.v:servername.' --remote-silent +\%{line} \%{input}" --synctex-forward='.input.' '.a:file.' &'
  let execstr = 'zathura -x "gvim --servername '.v:servername
				\ .' --remote-silent +exec\%{line} \%{input}" --synctex-forward='
				\ .input.' '.a:file.' &'
  silent call system(execstr)
endfunction

function! s:TeXViewPDF(pdf_file)
	if has("unix")
		call <SID>ZathuraSynctexForward(a:pdf_file)
	elseif has('win32') || has ('win64')
		call <SID>SumatraSynctexForward(a:pdf_file)
	endif
endfunction
"}}}

function! s:TeXCompileCloseHandler(viewpdf,file,channel) "{{{CloseHandler
	if empty(b:tex_compile_errors)
		cclose
		echo "successfully compiled"
		let pdf_file = fnamemodify(a:file,':p:r').'.pdf'
		if a:viewpdf 
			silent! call <SID>TeXViewPDF(fnameescape(pdf_file))
		endif
	else 
		let log_file = fnamemodify(a:file,':p:r').'.log'
		let engine = b:tex_engine
		let log_content = readfile(log_file)
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

"{{{ RunLaTeX_job(file,dir,engine,view) 
"let b:tex_proj_dir = expand('%:p:h')
let b:tex_engine_options = '-synctex=1 -file-line-error -interaction=nonstopmode'
let b:tex_job_options = {
			\ 'out_io': 'pipe',
			\ 'out_cb': function('s:TeXCompileOutHandler'),
			\ 'close_cb': function('s:TeXCompileCloseHandler',[0,'']),
			\ }
function! RunLaTeX_job(file,dir,engine,view)
	let proj_dir = fnameescape(a:dir)
	let tex_file = fnameescape(a:file)
	"exec 'lcd ' . proj_dir
	let b:tex_compile_errors = [] 
	let job_options = copy(b:tex_job_options)
	let job_options['close_cb'] = function('s:TeXCompileCloseHandler',[a:view,a:file])
	if has('unix')
		let tex_cmd = 'cd ' . proj_dir . ' && ' . a:engine . ' '
					\ . b:tex_engine_options. ' ' . tex_file
		let cmd = ['/bin/sh', '-c', tex_cmd]
	elseif has('win32') || has('win64')
		let tex_cmd = 'cd /d ' . proj_dir . ' && ' . a:engine . ' '
					\ . b:tex_engine_options. ' ' . tex_file
		let cmd = &shell . ' /c ' . tex_cmd
	endif
	call setqflist([])
	let b:run_tex_job = job_start(cmd, job_options)
	"call timer_start(120000,function('s:TeXCheckJobStatus'))
endfunction
"}}}

""{{{ RunLaTeX(file,dir,engine,view)
function! RunLaTeX(file,dir,engine,view)
	let dir_old = getcwd()
	let proj_dir = fnameescape(a:dir)
	exec 'lcd ' . proj_dir
	let pdf_file = fnamemodify(a:file,':p:r').'.pdf'
	silent setlocal shellpipe=>
	call setqflist([]) " clear quickfix
	let makeprg_old = &makeprg
	let &makeprg = a:engine.' '.b:tex_engine_options.' '.fnameescape(a:file)
	silent make!  
	let &makeprg = makeprg_old
	exec 'lcd ' . dir_old
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
		if a:view
			silent! call <SID>TeXViewPDF(fnameescape(pdf_file))
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
	let save_cursor= [bufnr("%"),line("."),col("."),0]
	let b:tmp_cursor = save_cursor[1:2]
	let b:tmp_source = expand("%:p")

	" find TeX engine
	if a:engine == 'auto'
		if !exists('b:tex_engine')
			" Get the TeX engine from the line % !TeX engine/grogram = pdflatex/xelatex
			let l:current_file = expand('%:p')
			let com_str = '^\c\s*%.\{-}\(pdf\|xe\|lua\)latex\(\s.*\)*$' 
			"let com_str = '^\c\s*%\+.\{-}\(!\)*\s*\(TeX\)*\s*\(engine\|program\)*\s*\(=\|:\)*\s*\(pdf\|xe\|lau\)*latex.*'
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
				let  tex_engine_pre = substitute(line_text,com_str,'\1','')
				let b:tex_engine = tolower(tex_engine_pre) . 'latex'
			endif
		endif
	else 
		let b:tex_engine = a:engine
	endif

	""compile latex 
	echomsg "compiling with ".b:tex_engine."..."
	if v:version >= 801
		silent! call RunLaTeX_job(b:tex_main_file_name,b:tex_proj_dir,b:tex_engine,a:view)
	else
		silent! call RunLaTeX(b:tex_main_file_name,b:tex_proj_dir,b:tex_engine,a:view)
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
	if !exists('b:tex_main_file_name')  || !exists('b:tex_proj_dir')|| (b:tex_main_file_name == '')
		let [b:tex_main_file_name,b:tex_proj_dir] = Find_Main_TeX_File()
	endif
	exec 'lcd ' . fnameescape(b:tex_proj_dir)
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
	if !exists('b:tex_main_file_name')  || !exists('b:tex_proj_dir')|| (b:tex_main_file_name == '')
		let [b:tex_main_file_name,b:tex_proj_dir] = Find_Main_TeX_File()
	endif
	exec 'lcd ' . fnameescape(b:tex_proj_dir)
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

function! s:TeX_Compile_Paragraph(engine) "{{{
	silent write
	let cur_cursor= [line("."),col(".")]
	let curdir = expand("%:p:h")
	if getftype('tmp') != 'dir'
		call mkdir('tmp')
	endif
	"find the preamble
	if exists('b:doc_begin_doc') && (b:doc_begin_doc > 0)
		let preamble = getline(1,b:doc_begin_doc)
		let curtexfname = expand("%:t:r")
	else
		let [b:tex_main_file_name,b:tex_proj_dir] = Find_Main_TeX_File()
		if b:tex_main_file_name == ''
			echomsg "no main tex file be found!" 
			return ''
		else
			let curtexfname = fnamemodify(b:tex_main_file_name,':p:t:r')
			let mainfile_content = readfile(b:tex_main_file_name) 
			let preamble = []
			for item in mainfile_content
				call add(preamble,item)
				if item =~ '^\s*\\begin\s*{\s*document\s*}'
					break
				endif
			endfor
		endif
	endif
	"find the tex engine
	if a:engine == 'auto'
		if !exists('b:tex_engine')
			let com_pattern = '^\c\s*%.\{-}\(pdf\|xe\|lua\)latex\(\s.*\)*$' 
			let engine_pre = ''
			for item in preamble 
				if item =~ com_pattern
					let engine_pre = substitute(item,com_pattern,'\1','')
					break
				endif
			endfor
			if engine_pre == ''
				let b:tex_engine = 'pdflatex'
			else
				let b:tex_engine = tolower(engine_pre.'latex')
			endif
		endif
	else
		let b:tex_engine = a:engine
	endif
	"find the current paragraph
	let start_pos = search('^\s*\\\(chapter\|\(sub\)*section\|appendix\|begin\s*{\s*document\s*}\)','bcnW')
	let end_pos = search('^\s*\\\(chapter\|\(sub\)*section\|appendix\|end\s*{\s*document\s*}\)','nW')
	if start_pos == 0
		let start_pos = 1
	elseif getline(start_pos) =~ '^\s*\\begin\s*{\s*document\s*}'
		let start_pos = start_pos + 1
	endif
	if end_pos == 0
		let end_pos = line('$')
	else
		let end_pos = end_pos - 1
	endif
	"compile the paragraph 
	if start_pos >= end_pos
		return '' 
	else
		let content = getline(start_pos,end_pos)
		let compile_part = extend(copy(preamble), content)
		call add(compile_part,'\end{document}')
		let tmp_file =  curdir.'/tmp/'.curtexfname.'_tmp.tex'
		let tmp_dir = curdir . '/tmp'
		call writefile(compile_part,tmp_file)
		let b:tmp_cursor = [len(preamble) + cur_cursor[0] - start_pos + 1,cur_cursor[1]]
		let b:tmp_source = tmp_file
		echomsg "compiling the current paragraph with ".b:tex_engine."..."
		if v:version >= 801
			silent call RunLaTeX_job(tmp_file,tmp_dir,b:tex_engine,1)
		else
			silent call RunLaTeX(tmp_file,tmp_dir,b:tex_engine,1)
		endif
	endif
endfunction
"}}}

nnoremap <silent> <buffer><F2>  :call <SID>Compile_LaTeX_Run('auto',1)<CR>
nnoremap <silent> <buffer><S-F2>  :call <SID>Compile_LaTeX_Run('pdflatex',1)<CR>
nnoremap <silent> <buffer><F6>  :call <SID>Compile_LaTeX_Run("xelatex",1)<CR> 
nnoremap <silent> <buffer><F8> :call <SID>CompileBibTeX()<CR>
nnoremap <silent> <buffer><C-c> : call <SID>TeXCancelJob()<CR>
nnoremap <silent> <buffer><F3> : call <SID>TeX_Compile_Paragraph('auto')<CR>
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
