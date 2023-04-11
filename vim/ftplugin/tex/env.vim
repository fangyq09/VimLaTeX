if exists('b:tex_envs')
	finish
endif

let b:tex_envs = 1


"Get env name, begin pos, end pos and length of the env
function! GetTeXEnv(mode,...) "{{{1
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
			let str_envend = ')\|]\|\\}\|\\rangle'
			let str_envstart = '(\|[\|\\{\|\\langle'
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

""{{{1 let s:KeyEnvList =
let s:KeyEnvList = [
			\ ['\\[', '\[', '\]'],
			\ ["\\$", '$', '$'],
			\ ['eq\%[uation]', '\begin{equation}\label{eq:}', '\end{equation}'],
			\ ['\(ald\|aligned\)', '\begin{aligned}', '\end{aligned}'],
			\ ['al\%[ign]', '\begin{align}', '\end{align}'],
			\ ['ga\%[thered]', '\begin{gathered}', '\end{gathered}'],
			\ ['\(thm\|theo\%[rem]\)', '\begin{theorem}', '\end{theorem}'],
			\ ['prop\%[osition]', '\begin{proposition}', '\end{proposition}'],
			\ ['co\%[rollary]', '\begin{corollary}', '\end{corollary}'],
			\ ['le\%[ema]', '\begin{lemma}', '\end{lemma}'],
			\ ['re\%[mark]', '\begin{remark}', '\end{remark}'],
			\ ['item\%[ize]', '\begin{itemize}', '\end{itemize}'],
			\ ['enu\%[merate]', '\begin{enumerate}', '\end{enumerate}'],
			\ ['des\%[cription]', '\begin{description}','\end{description}'],
			\ ['prob\%[lem]', '\begin{problem}', '\end{problem}'],
			\ ['exe\%[rcise]', '\begin{exercise}', '\end{exercise}'],
			\ ['exa\%[mple]', '\begin{example}', '\end{example}']
			\	]
"}}}1

"change env 
function! s:Change(mode,old_env,name,...) "{{{1

	let oldenv_name = a:old_env[0]
	let oldenv_startline = a:old_env[1][0]
	let oldenv_startcol = a:old_env[1][1]
	let oldenv_endline = a:old_env[2][0]
	let oldenv_endcol = a:old_env[2][1]
	let oldenv_startlen = a:old_env[3][0]
	let oldenv_endlen = a:old_env[3][1]
	let str_startl = '\(\\left\|\\big\|\\Big\|\\bigg\|\\Bigg\)\=\((\|[\|\\{\|\\langle\)'

	if a:name == ''
		return 0
	endif

	if a:mode == 'com'
		let new_env = matchlist(a:name,str_startl)
		let first = escape(a:name,'\')
		if new_env[1] == "\\left"
			let sec_pre = '\right'
		else
			let sec_pre = new_env[1]
		endif
		if new_env[2] == '('
			let sec_clo = ')'
		elseif new_env[2] == '['
			let sec_clo = ']'
		elseif new_env[2] == "\\{"
			let sec_clo = '\}'
		elseif new_env[2] == "\\langle"
			let sec_clo = '\rangle'
		endif
		let second = escape(sec_pre.sec_clo,'\')
	else
		let count_num = 0
		while count_num <= len(s:KeyEnvList)-1
			if a:name =~ '^'.s:KeyEnvList[count_num][0]
				let first = s:KeyEnvList[count_num][1]
				let second = s:KeyEnvList[count_num][2]
				break
			endif
				let count_num = count_num + 1
		endwhile
		if count_num == len(s:KeyEnvList)
			let first = '\begin{'.a:name.'}'
			let second = '\end{'.a:name.'}'
		endif
	endif

	if a:mode == 'com'
		let oldendline = getline(oldenv_endline)
		let subsb = oldenv_endcol-1
		let newendline = substitute(oldendline,".\\{".subsb."}\\zs.\\{".oldenv_endlen."}\\ze",second,"")
		call setline(oldenv_endline,newendline)
		let oldstartline = getline(oldenv_startline)
		let subse = oldenv_startcol-1
		let newstartline = substitute(oldstartline,".\\{".subse."}\\zs.\\{".oldenv_startlen."}\\ze",first,"")
		call setline(oldenv_startline,newstartline)
		return
	endif

	if oldenv_name == 'ilm'
		let oldendline = getline(oldenv_endline)
		let newendline1 = strpart(oldendline,0,oldenv_endcol-1)
		let newendline3 = strpart(oldendline,oldenv_endcol)
		let periodmark = strpart(oldendline,oldenv_endcol,1)
		if periodmark =~',\|.\|;\|?'
			let newendline1 = newendline1.periodmark
			let newendline3 = strpart(oldendline,oldenv_endcol+1)
		endif 
		if newendline1 =~ '\S'
			call setline(oldenv_endline,newendline1)
			if newendline3 =~ '\S'
				call append(oldenv_endline,[second,newendline3])
			else
				call append(oldenv_endline,second)
			endif
		else
			call setline(oldenv_endline,second)
			if newendline3 =~ '\S'
				call append(oldenv_endline,newendline3)
			endif
		endif
		let oldstartline = getline(oldenv_startline)
		let newstartline1 = strpart(oldstartline,0,oldenv_startcol-1)
		let newstartline3 = strpart(oldstartline,oldenv_startcol)
		if newstartline1 =~ '\S'
			call setline(oldenv_startline,newstartline1)
			if newstartline3 =~ '\S'
				call append(oldenv_startline,[first,newstartline3])
			else
				call append(oldenv_startline,first)
			endif
		else
			call setline(oldenv_startline,first)
			if newstartline3 =~ '\S'
				call append(oldenv_startline,newstartline3)
			endif
		endif
	elseif oldenv_name == 'sdm'
		if  a:name =~ 'ald\|aligned\|ga\%[thered]\|array'
			call append(oldenv_endline-1,second)
			call append(oldenv_startline,first)
		else
			call setline(oldenv_endline,second)
			call setline(oldenv_startline,first)
		endif
	else
		call setline(oldenv_endline,second)
		call setline(oldenv_startline,first)
	endif
endfunction
"}}}
"
function! Tex_env_change(mode) "{{{1
	if (a:mode == "com" || a:mode == "math") && (tex#outils#ismath("texMathZone")==0)
		echomsg "You are not inside environment !"
		return
	endif
	let old_env = GetTeXEnv(a:mode)
	let prefixdict= {'0': '', '1': '\left', '2': '\big', '3': '\Big', '4': '\bigg', '5': '\Bigg'}
	let envdict= {'0': '', '1': '(', '2': '[', '3': '\{', '4': '\langle'}
	if old_env[0] == ''
		if a:mode == "com"
			echomsg "no surrounding!"
		else
			echomsg "not in any environment!"
		endif
		return 0
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
			let newenvpair = split(inputnewpair,'\zs')
			let newenv = get(prefixdict,newenvpair[0]) . get(envdict,newenvpair[1])
		else
			return 0
		endif
	else
		let newenv = input('change it to:')
	endif
	call <SID>Change(a:mode,old_env,newenv)
endfunction
"}}}1


nnoremap <silent><buffer><F3> :call Tex_env_change('com')<cr>
nnoremap <silent><buffer><F4> :call Tex_env_change('math')<cr>
nnoremap <silent><buffer><F5> :call Tex_env_change('env')<cr>

" vim:fdm=marker:noet:ff=unix

