"=============================================================================
" 	     File: omni.vim
"      Author: Yangqin Fang
"       Email: fangyq09@gmail.com
" 	  Version: 1.1 
"     Created: 06/04/2013
" 
"  Description: An omni completion of LaTeX
"=============================================================================
if exists('b:tex_omni')
	finish
endif

let b:tex_omni = 1
if has('unix')
	let b:glob_option = '\c'
else 
	let b:glob_option = ''
endif

let s:completiondatadir=expand("<sfile>:p:h") ."/completion/"
let s:tex_unicode =s:completiondatadir . "unicodemath.txt"
let s:tex_commands =s:completiondatadir . "commands.txt"
let s:tex_env_data =s:completiondatadir . "environments.txt"
let s:tex_packages_data =s:completiondatadir . "packages.txt"
let s:tex_fonts_data =s:completiondatadir . "fonts.txt"

function! s:NextCharsMatch(regex)
	let rest_of_line = strpart(getline('.'), col('.') - 1)
	return rest_of_line =~ a:regex
endfunction

"{{{ Find the bibtex source
"only support one bib file
function! TeX_Find_BiB_Source()
	let bib_name = ''
	let bib_line_num = search('\s*\\\(bibliography\|addbibresource\)\s*{.*}','cnw')
	if bib_line_num
		let biblio_line = getline(bib_line_num)
		let bib_name = matchstr(biblio_line, '.*{\zs.*\ze\s*}')
	endif
	return bib_name
endfunction
"}}}

"{{{ Find bib items
function! TeX_Find_bibref_items(pattern,file,type)
	let result = []
	let sub_res = []
	if a:file != '*.tex'
		let bib_file = readfile(a:file)
	endif
	call setqflist([]) " clear quickfix
	exec 'silent! vimgrep! "'.a:pattern.'"j '.a:file
	for i in getqflist()
		let itext = i.text
		let ifilename = bufname(i.bufnr)
		if a:file != '*.tex'
			let next_line = bib_file[i.lnum]
			let next_line2 = bib_file[i.lnum + 1]
			let next_line = substitute(next_line,'\s\+',' ','g')
			let next_line2 = substitute(next_line2,'\s\+',' ','g')
			let app_line_add = next_line.' '.next_line2
		else
			let app_line_add = ''
		endif
		if a:type == 'cite'
			let prefix = matchstr(itext,'^.*{\s*\zs.*\ze\s*,\s*')
		elseif a:type == 'ref'
			let prefix = matchstr(itext,'\\label\s*{\s*\zs.*\ze\s*}')
		endif
		call add(result,[prefix,itext.' '.app_line_add,ifilename])
	endfor
	return result
endfunction
"}}}

inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

setlocal omnifunc=TEXOMNI
let s:completion_type = ''

function! TEXOMNI(findstart, base)  "{{{1
		let line = getline('.')
	if a:findstart
		" return the starting position of the word
		let pos = col('.') - 1
		while pos > 0 && line[pos - 1] !~ '\(\\\|{\|\[\|,\|=\|\s\)'
			let pos -= 1
		endwhile

		if line[pos - 1] == '\'
			let pos -= 1
		endif
		let b:omni_start_pos = pos
		return pos
	else
		" return suggestions in an array
		let suggestions = []
		let text = getline(".")[0:col(".")-2]
		let curdir = expand("%:p:h")
		let com_prefix = escape(a:base, '\')
		if com_prefix =~ '^\\.*'
			" suggest known commands
			if filereadable(s:tex_commands) || filereadable(s:tex_unicode)
				let com_list = extend(readfile(s:tex_commands),readfile(s:tex_unicode))
				for entry in com_list
					if entry =~ '^' . escape(a:base, '\')
						call add(suggestions, entry)
					endif
				endfor
			endif
		elseif text =~ '\\\(begin\|end\)\s*{'
			" suggest known environments
			if filereadable(s:tex_env_data)
				let env_list = readfile(s:tex_env_data)
				for entry in env_list
					if entry =~ '^' . escape(a:base, '\')
						if !s:NextCharsMatch('}')
							let entry = entry . '}'
						endif
						call add(suggestions, entry)
					endif
				endfor
			endif
		elseif text =~ '\\set\(CJK\)\=\(main\|sans\|mono\|math\|family\)font\(\[[^\]]*\]\)*\s*\(\[\|{\)'
			" suggest known environments
			if filereadable(s:tex_fonts_data)
				let font_list = readfile(s:tex_fonts_data)
				for entry in font_list
					if entry =~ '^' . escape(a:base, '\')
						if !s:NextCharsMatch('}') && (line[b:omni_start_pos - 1] == '{')
							let entry = entry . '}'
						endif
						call add(suggestions, entry)
					endif
				endfor
			endif
		elseif text =~ '\\\(usepackage\|RequirePackage\)\(\[[^\]]*\]\)*\s*{'
			" suggest known environments
			if filereadable(s:tex_packages_data)
				let pkgs_list = readfile(s:tex_packages_data)
				for entry in pkgs_list
					if entry =~ '^' . escape(a:base, '\')
						call add(suggestions, entry)
					endif
				endfor
			endif
		elseif text.com_prefix =~ '\\\(input\|include\)\_\s*{'.com_prefix
			let texfiles1 = glob(curdir.'/*.'.b:glob_option.'tex')
			let texfiles2 = glob(curdir.'/*/*.'.b:glob_option.'tex')
			let texfiles = split(texfiles1, '\n') + split(texfiles2, '\n')
			for tex in texfiles
				let tex_c = substitute(tex,"^".curdir."/","","") 
				if tex_c =~ '^'.a:base
					if !s:NextCharsMatch('}')
						let tex_c = tex_c . '}'
					endif
					call add(suggestions,tex_c)
				endif
			endfor
		elseif text =~ '\\include\(graphics\|pdf\|pdfmerge\|svg\)\(\[[^\]]*\]\)*\s*{'
			let searchstr = '\(pdf\|jpg\|jpeg\|png\|eps\|bmp\|svg\)'
			if com_prefix =~ '^\.'
				let pictures1 = glob('./*.'.b:glob_option.searchstr)
			else
				let pictures1 = glob('*.'.b:glob_option.searchstr)
			endif
			let pictures2 = glob('./*/*.'.b:glob_option.searchstr)
			let pictures = split(pictures1, '\n') + split(pictures2, '\n')
			for pic in pictures
				if pic =~ '^'.a:base
					if !s:NextCharsMatch('}')
						let pic = pic . '}'
					endif
					call add(suggestions,pic)
				endif
			endfor
		elseif text.com_prefix =~ '\\cite\s*\(\[[^\]]*\]\)*\s*{\([^}]\)*'.com_prefix
			echomsg [text, com_prefix]
			if !exists('b:tex_bib_name')
				let b:tex_bib_name = TeX_Find_BiB_Source()
			endif
			if b:tex_bib_name != ''
				let bib_source = substitute(b:tex_bib_name,'.bib\s*$','','')
				let bib_pattern = '^\s*@.*{'.com_prefix
				let bib_item_li = TeX_Find_bibref_items(bib_pattern,bib_source.'.bib','cite')
				if len(bib_item_li)>0
					for bib_item in bib_item_li
						call add(suggestions, {'word': bib_item[0], 'dup': 1,
									\ 'abbr': bib_item[1]})
					endfor
				endif
			endif
		elseif text.com_prefix =~ '\\\(ref\|eqref\|label\)\s*{'.com_prefix
			if exists('b:doc_class_line') && b:doc_class_line
				let file_name = expand("%:p:t")
			elseif search('\s*\\documentclass','cnw')
				let file_name = expand("%:p:t")
			else
				let file_name = '*.tex'
			endif
			let label_pattern = '\\label\s*{'.com_prefix
			let label_item_li = TeX_Find_bibref_items(label_pattern,file_name,'ref')
			if text =~ '\\\(ref\|eqref\)\s*{'
				for label_item in label_item_li
					call add(suggestions, {'word': label_item[0], 'dup': 1,
								\ 'abbr': label_item[1], 'menu': label_item[2]})
				endfor
			else
				for label_item in label_item_li
					call add(suggestions, {'word': a:base, 'dup': 1, 'empty': 1,
								\ 'abbr': label_item[1], 'menu': label_item[2]})
				endfor
			endif
		endif
		if !has('gui_running')
			redraw!
		endif
		return suggestions
	endif
endfunction
"}}}1

" vim:fdm=marker:noet:ff=unix
