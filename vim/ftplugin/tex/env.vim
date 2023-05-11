if exists('b:loaded_vimtextric_envs')
	finish
endif

let b:loaded_vimtextric_envs = 1


let s:tex_prefix = [
			\ ['',''],
			\ ['\left','\right'],
			\ ['\big','\big'],
			\ ['\Big','\Big'],
			\ ['\bigg','\bigg'],
			\ ['\Bigg','\Biggg']
			\ ]
let s:tex_parentheses = [
			\ ['',''],
			\ ['(',')'],
			\ ['[',']'],
			\ ['\{','\}'],
			\ ['\langle','\rangle'],
			\ ['\lvert','\rvert'],
			\ ['\lVert','\rVert']
			\ ]
""{{{ let s:tex_KeyEnvList =
let s:tex_KeyEnvList = [
			\ ['eq\%[uation]', 'equation', '\label{eq:}'],
			\ ['\(ald\|aligned\)', 'aligned', ''],
			\ ['al\%[ign]', 'align', ''],
			\ ['ga\%[thered]', 'gathered', ''],
			\ ['\(thm\|theo\%[rem]\)', 'theorem', ''],
			\ ['prop\%[osition]', 'proposition', ''],
			\ ['co\%[rollary]', 'corollary', ''],
			\ ['le\%[ema]', 'lemma', ''],
			\ ['re\%[mark]', 'remark', ''],
			\ ['item\%[ize]', 'itemize', ''],
			\ ['enu\%[merate]', 'enumerate', '[label={(\arabic*)}]'],
			\ ['des\%[cription]', 'description', ''],
			\ ['prob\%[lem]', 'problem', ''],
			\ ['exe\%[rcise]', 'exercise', ''],
			\ ['exa\%[mple]', 'example', ''],
			\ ['cas\%[es]', 'cases', ''],
			\ ['ncas', 'numcases', '{}'],
			\ ['ar\%[ray]', 'array', '{}'],
			\ ['cen\%[ter]', 'center', ''],
			\ ['tabl\%[e]', 'table', '\label{tab:}\centering\caption{}'],
			\ ['tabu\%[lar]', 'tabular', '{}'],
			\ ['fig\%[ure]', 'figure', '[H]\label{fig:}\centering\caption{}']
			\	]
"}}}

let s:tex_inside_envs = ['aligned', 'gathered', 'array', 'cases', 'split']
let s:tex_outside_envs = ['center', 'figure', 'table']
"Get env name, begin pos, end pos and length of the env
function! GetTeXEnv(mode) "{{{1
	let pos = getpos('.')
	let win = winsaveview()
	let env_name = ''
	let searchbackward_ops = 'bWc'
	let searchforward_ops = 'Wc'
	let b_start = [line('.'),col('.')]
	let b_end = [line('.'),col('.')]
	let cursor_save = [line('.'),col('.')]
	let carry_on = 1
	let env_open=''
	let env_close=''
	let reslut=['',[0,0],[0,0],[0,0]]
	if a:mode=='env'
		let searchforward_ops = 'W'
		while carry_on
			keepjumps let b_end = searchpos('\\end{\|\\]',searchforward_ops)
			let search_ops = 'W'
			" Only accept a match at the cursor position on the
			" first cycle, otherwise we wouldn't go anywhere!
			let l:curline = strpart(getline('.'),col('.')-1,20)
			if l:curline =~ '\\end{'
				let env_name = matchstr(getline('.'),'\\end{\zs.\{-}\ze}')
				let env_esc = escape(env_name,'*')
				let env_open = '\\begin{\s*'.env_esc.'\s*}'
				let env_close = '\\end{\s*'.env_esc.'\s*}'
				let end_len = matchend(l:curline,env_close)
			elseif l:curline =~ '\\]'
				let env_name = 'sdm'
				let env_open = '\\\['
				let env_close = '\\\]'
				let end_len = 2
			endif
			keepjumps let b_start = searchpairpos(env_open,'',env_close,'bWn')
			let start_env_part = strpart(getline(b_start[0]),b_start[1]-1,20)
			let start_len = matchend(start_env_part,env_open)
			if TexComPos(b_start,cursor_save) >0
				let carry_on = 0
				let result = [env_name,b_start,b_end,[start_len,end_len]]
			endif
		endwhile
	elseif a:mode == 'math'
		let cl = line('.')
		let cc = col('.')
		if tex#outils#ismath("texMathZoneX")
			let b_start = searchpos('\$','bWc')
			let b_end = searchpos('\$','Wn')
			let result = ['ilm',b_start,b_end,[1,1]]
		else
			let result = ['',[0,0],[0,0],[0,0]]
		endif
	elseif a:mode == 'com'
		if tex#outils#ismath("texMathZone")==0
			let result = ['',[0,0],[0,0],[0,0]]
		else
			let result = ['',[0,0],[0,0],[0,0]]
			let maxpos = searchpos('\\end{\|\\]\|\$','Wn')
			let minipos = searchpos('\\begin{\|\\[\|\$','bWn')
			let prefix_ls = '\\left\|\\big\|\\Big\|\\bigg\|\\Bigg'
			let prefix_rs = '\\right\|\\big\|\\Big\|\\bigg\|\\Bigg'
			let str_envend = ')\|]\|\\}\|\\rangle\|\\rvert\|\\rVert'
			let str_envstart = '(\|[\|\\{\|\\langle\|\\lvert\|\\lVert'
			let str_search =  '\('.prefix_ls.'\)\=\('.str_envstart.'\)'
			let l:pair = 0
			while l:pair == 0 
				if (TexComPos(minipos,b_start) < 0) || (TexComPos(b_end,maxpos) < 0)
					break
				endif 
				keepjumps let b_stop = searchpos(str_search,searchbackward_ops)
				let cp = [line('.'),col('.')]
				if TexComPos(minipos,cp) < 0
					break
				endif
				let searchbackward_ops = 'bW'
				let preenv = strpart(getline('.'),col('.')-1,20)
				let leftenv = matchlist(preenv,str_search)
				let prefix_l = leftenv[1]
				let envname_l = leftenv[2]
				let rightenv = <SID>Get_pair_right(prefix_l,envname_l)
				let prefix_r = rightenv[0]
				let envname_r = rightenv[1]
				let env_name = prefix_l.envname_l
				let env_bg = escape(prefix_l,'\').escape(envname_l,'\[')
				let env_end = escape(prefix_r,'\').escape(envname_r,'\]')
				let start_len = strlen(prefix_l)+strlen(envname_l)
				keepjumps let f_stop = searchpairpos(env_bg,'',env_end,'Wn')
				let end_len = strlen(prefix_r)+strlen(envname_r)
				let envendpos = [f_stop[0],f_stop[1]+end_len-1]
				if TexComPos(cursor_save,envendpos) >0
					let result = [env_name,b_stop,f_stop,[start_len,end_len]]
					let l:pair = 1
				endif
			endwhile
		endif
	endif
	call setpos('.',pos)
	call winrestview(win)
	return result
endfunction
	"}}}

function! TexComPos(pos1,pos2) "{{{1
		if a:pos1[0] < a:pos2[0]
			return 1
	elseif a:pos1[0] == a:pos2[0] && a:pos1[1] <= a:pos2[1]
		return 1
	else
		return -1
	endif
endfunction
"}}}1

function! s:Get_pair_right(prefixleft,envnameleft) "{{{1
	if a:prefixleft == "\\left"
		let prefixright = "\\right"
	else
		let prefixright = a:prefixleft
	endif
	if a:envnameleft == '('
		let envnameright = ')'
	elseif a:envnameleft == '['
		let envnameright = ']'
	elseif a:envnameleft == "\\{"
		let envnameright = "\\}"
	elseif a:envnameleft == "\\langle"
		let envnameright = "\\rangle"
	endif
	return [prefixright,envnameright]
endfunction
"}}}1


function! s:Change_surroundings(mode,old_env,name) "{{{

	let oldenv_name = a:old_env[0]
	let oldenv_startline = a:old_env[1][0]
	let oldenv_startcol = a:old_env[1][1]
	let oldenv_endline = a:old_env[2][0]
	let oldenv_endcol = a:old_env[2][1]
	let oldenv_startlen = a:old_env[3][0]
	let oldenv_endlen = a:old_env[3][1]

	if empty(a:name)
		return ''
	endif

	if a:mode == 'com'
		let first_anchor = a:name[0]
		let second_anchor = a:name[1]
		let first = s:tex_prefix[first_anchor][0] . s:tex_parentheses[second_anchor][0]
		let second = s:tex_prefix[first_anchor][1] . s:tex_parentheses[second_anchor][1]
		let first = escape(first,'\')
		let second = escape(second,'\')
		let oldendline = getline(oldenv_endline)
		let subsb = oldenv_endcol-1
		let newendline = substitute(oldendline,".\\{".subsb."}\\zs.\\{".oldenv_endlen."}\\ze",second,"")
		call setline(oldenv_endline,newendline)
		let oldstartline = getline(oldenv_startline)
		let subse = oldenv_startcol-1
		let newstartline = substitute(oldstartline,".\\{".subse."}\\zs.\\{".oldenv_startlen."}\\ze",first,"")
		call setline(oldenv_startline,newstartline)
	elseif oldenv_name == 'ilm'
		let delta = oldenv_endline - oldenv_startline + 4
		let oldendline = getline(oldenv_endline)
		"let endline_indent = matchstr(oldendline,'^\s*')
		if a:name[0] == 'sdm'
			let first = '\['
			let second = '\]'
		else
			let first = '\begin{'.a:name[0].'}'.a:name[1]
			let second = '\end{'.a:name[0].'}'
		endif
		let newendline1 = strpart(oldendline,0,oldenv_endcol-1)
		let periodmark = strpart(oldendline,oldenv_endcol,1)
		if periodmark =~'\(,\|\.\|;\|?\)'
			let newendline1 = newendline1.periodmark
			let newendline3 = strpart(oldendline,oldenv_endcol+1)
		else
			let newendline3 = strpart(oldendline,oldenv_endcol)
		endif 
		let end_app_list = [newendline1,second,newendline3]
		let end_app_list = filter(end_app_list, 'v:val !~ "^\\s*$"')
		let end_app_position = oldenv_endline - 1
		exec oldenv_endline . 'delete'
		call append(end_app_position,end_app_list)

		let oldstartline = getline(oldenv_startline)
		"let startline_indent = matchstr(oldstartline,'^\s*')
		let newstartline1 = strpart(oldstartline,0,oldenv_startcol-1)
		let newstartline3 = strpart(oldstartline,oldenv_startcol)
		let start_app_list = [newstartline1,first,newstartline3]
		let start_app_list = filter(start_app_list, 'v:val !~ "^\\s*$"')
		let start_app_position = oldenv_startline - 1
		exec oldenv_startline . 'delete'
		call append(start_app_position,start_app_list)
		silent! exec 'normal! ' . oldenv_startline . 'G' . delta . '==' 
	elseif oldenv_name == 'sdm'
		if a:name[0] == '$'
			let oldendline = getline(oldenv_endline)
			let oldenv_endline_pre = getline(oldenv_endline - 1)
			if oldendline =~ '^\s*\\]\s*$'
				exec oldenv_endline . 'delete'
				let newenv_endline_pre = substitute(oldenv_endline_pre,'\s*$','','') . '$'
				call setline(oldenv_endline-1,newenv_endline_pre)
			endif
			let oldstartline = getline(oldenv_startline)
			let oldenv_startline_aft = getline(oldenv_startline+1)
			let startline_indent = matchstr(oldstartline,'^\s*')
			if oldstartline =~ '^\s*\\[\s*$'
				exec oldenv_startline . 'delete'
				let newenv_startline_aft = startline_indent . '$' 
							\ . substitute(oldenv_startline_aft,'^\s*','','')
				call setline(oldenv_startline,newenv_startline_aft)
			endif
			let delta = oldenv_endline - oldenv_startline  + 1
			silent! exec 'normal! ' . oldenv_startline . 'G' . delta . '==' 
		elseif a:name[0] == 'sdm'
			return ''
		else
			let first = '\begin{'.a:name[0].'}'.a:name[1]
			let second = '\end{'.a:name[0].'}'
			if index(s:tex_inside_envs, a:name[0]) >= 0
				call append(oldenv_endline-1,second)
				call append(oldenv_startline,first)
				let delta = oldenv_endline - oldenv_startline + 3
				silent! exec 'normal! ' . oldenv_startline . 'G' . delta . '==' 
			else
				call setline(oldenv_endline,second)
				call setline(oldenv_startline,first)
				let delta = oldenv_endline - oldenv_startline + 1
				silent! exec 'normal! ' . oldenv_startline . 'G' . delta . '==' 
			endif
		endif
	else
		if a:name[0] == '$'
			let oldendline = getline(oldenv_endline)
			let oldenv_endline_pre = getline(oldenv_endline - 1)
			exec oldenv_endline . 'delete'
			let newenv_endline_pre = substitute(oldenv_endline_pre,'\s*$','','') . '$'
			call setline(oldenv_endline-1,newenv_endline_pre)
			let oldstartline = getline(oldenv_startline)
			let oldenv_startline_aft = getline(oldenv_startline+1)
			let startline_indent = matchstr(oldstartline,'^\s*')
			exec oldenv_startline . 'delete'
			let newenv_startline_aft = startline_indent . '$' 
						\ . substitute(oldenv_startline_aft,'^\s*','','')
			call setline(oldenv_startline,newenv_startline_aft)
			let delta = oldenv_endline - oldenv_startline  + 1
			silent! exec 'normal! ' . oldenv_startline . 'G' . delta . '==' 
		elseif a:name[0] == 'sdm'
			let first = '\['
			let second = '\]'
			call setline(oldenv_endline,second)
			call setline(oldenv_startline,first)
			let delta = oldenv_endline - oldenv_startline + 1
			silent! exec 'normal! ' . oldenv_startline . 'G' . delta . '==' 
		else
			let new_env_name = a:name[0]
			if index(s:tex_outside_envs, new_env_name) >= 0
				let first = '\begin{'.a:name[0].'}'.a:name[1]
				let second = '\end{'.a:name[0].'}'
				call append(oldenv_endline,second)
				call append(oldenv_startline-1,first)
				let delta = oldenv_endline - oldenv_startline + 3
				silent! exec 'normal! ' . oldenv_startline . 'G' . delta . '==' 
			elseif index(s:tex_inside_envs, new_env_name) >= 0
				let first = '\begin{'.a:name[0].'}'.a:name[1]
				let second = '\end{'.a:name[0].'}'
				call append(oldenv_endline-1,second)
				call append(oldenv_startline,first)
				let delta = oldenv_endline - oldenv_startline + 3
				silent! exec 'normal! ' . oldenv_startline . 'G' . delta . '==' 
			else
				if new_env_name == '*'
					if strcharpart(oldenv_name, strchars(oldenv_name) - 1) == '*'
						let new_env_name = strcharpart(oldenv_name,0,strchars(oldenv_name) - 1)
					else
						let new_env_name = oldenv_name . '*'
					endif
				endif
				let oldenv_name = escape(oldenv_name,'*')
				let env_close_old = getline(oldenv_endline)
				let env_close_new = substitute(env_close_old,'\\end{'.oldenv_name.'}',
							\ '\\end{'.new_env_name.'}','')
				let env_open_old = getline(oldenv_startline)
				let env_open_new = substitute(env_open_old,'\\begin{'.oldenv_name.'}',
							\ '\\begin{'.new_env_name.'}','')
				call setline(oldenv_endline,env_close_new)
				call setline(oldenv_startline,env_open_new)
			endif
		endif
	endif
	return ''
endfunction
"}}}
function! s:TeX_change_env(mode) "{{{
	if (a:mode == "com" || a:mode == "math") && (tex#outils#ismath("texMathZone")==0)
		echo "You are not inside environment !"
		return
	endif
	let old_env = GetTeXEnv(a:mode)
	if old_env[0] == ''
		if a:mode == "com"
			echo "no surrounding!"
		else
			echo "not in any environment!"
		endif
		return ''
	else
		let nam = old_env[0]
		if nam == "sdm"
			let optn = "\\\[...\\\]"
		elseif nam == "ilm"
			let optn = "\$...\$"
		else
			let optn = nam 
		endif
	echo "You are in " | echohl WarningMsg | echon optn | echohl None | echon " environment"
	endif
	if a:mode == "com"
		let inputnewpair = input("change it to: nn \n (0); (1)\\left\\right; (2)\\big; (3)\\Big;   (4)\\bigg; \t (5)\\Bigg \n (0); (1)();   \t      (2)[];   (3)\\{\\};   (4)\\langle\\rangle \n")
		if strlen(inputnewpair) == 2 && ( inputnewpair != '\D' )
			let newenv = split(inputnewpair,'\zs')
		else
			return ''
		endif
	else
		let newenv_pre = input('change it to:')
		if newenv_pre =~ '\\['
			let newenv = ['sdm', '']
		else
			let count_num = 0
			while count_num <= len(s:tex_KeyEnvList)-1
				if newenv_pre =~ '^'.s:tex_KeyEnvList[count_num][0]
					let newenv = s:tex_KeyEnvList[count_num][1:]
					break
				endif
				let count_num = count_num + 1
			endwhile
			if count_num == len(s:tex_KeyEnvList)
				let newenv = [newenv_pre, '']
			endif
		endif
	endif
	call <SID>Change_surroundings(a:mode,old_env,newenv)
endfunction
"}}}1
"{{{https://stackoverflow.com/questions/1533565/how-to-get-visually-selected-text-in-vimscript
function! s:get_visual_selection()
    " Why is this not a built-in Vim script function?!
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
		if len(lines) == 0
			return ''
		else
			let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
			let lines[0] = lines[0][column_start - 1:]
			return join(lines, "\n")
		endif
endfunction
"}}}

function! s:TeX_add_surroundings()
endfunction
"vnoremap <C-i> :<C-u>call <SID>TeX_add_surroundings()<CR>
nnoremap <silent><buffer><F3> :call <SID>TeX_change_env('com')<cr>
nnoremap <silent><buffer><F4> :call <SID>TeX_change_env('math')<cr>
nnoremap <silent><buffer><F5> :call <SID>TeX_change_env('env')<cr>

" vim:fdm=marker:noet:ff=unix

