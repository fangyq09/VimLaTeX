"=============================================================================
" 	     File: template.vim
"      Author: Yangqin Fang
"       Email: fangyq09@gmail.com
" 	  Version: 1.1 
"     Created: 11/04/2013
" 
"  Description: A template plugin for LaTeX
"  it need directory ~/.vim/ftplugin/tex/template/
"  1. In the normal mode, press <F1>, the command line will appear the *.tex
"  templates under the dir ~/.vim/ftplugin/tex/template/, select the No., 
"  it will insert the selected template at the beginning of the document.
"  2. In the normal mode, press <F12>, the command line will appear the *.txt
"  templates under the dir ~/.vim/ftplugin/tex/template/, select the No., 
"  it will insert the selected template after the cursor line.
"  3. You can put your own templates in dir ~/.vim/ftplugin/tex/template/
"=============================================================================
if exists('b:tex_tamplate')
	finish
endif
let b:tex_template = 1

let s:templatedatadir=expand("<sfile>:p:h")."/template/"

function! ReadTeXTemplates(file,ipos)
	let temp_file = s:templatedatadir.a:file
	if filereadable(temp_file)
		let tex_temp = readfile(temp_file)
		call append(a:ipos,tex_temp)
	else
		echo 'No such template!'
	endif
endfunction

function! InsertTeXTemplates(type)
	let cur_line_num = line(".")
	if a:type == 'tex'
		let temp_list = glob(s:templatedatadir.'*.tex')
	elseif a:type == 'text'
		let temp_list = glob(s:templatedatadir.'*.txt')
	endif
	let temp_list = split(temp_list,'\n')
	let temp_list = map(temp_list, 'fnamemodify(v:val, ":t")')
	if !empty(temp_list)
		let num_temp_list = []
		for ii in range(len(temp_list))
			call add(num_temp_list,string(ii+1).'. '.temp_list[ii])
		endfor
		let output = join(num_temp_list,'; ')
		let name_num = input('Please choose the No. '.output.': ')
		let temp_name = temp_list[name_num-1]
		if a:type == 'tex'
			call ReadTeXTemplates(temp_name,0)
		elseif a:type == 'text'
			call ReadTeXTemplates(temp_name,cur_line_num)
		endif
	else
		echo 'No templates be found!'
	endif
endfunction

nmap <F1> <nop>
imap <F1> <nop>
nmap <silent><buffer><F1> :call InsertTeXTemplates('tex')<CR>
nmap <buffer><F12> :call InsertTeXTemplates('text')<CR>
