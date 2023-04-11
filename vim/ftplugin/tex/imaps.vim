"=============================================================================
" 	     File: imaps.vim
"      Author: Yangqin Fang
"       Email: fangyq09@gmail.com
" 	  Version: 1.1 
"     Created: 11/04/2013
" 
"  Description: An imaps plugin for LaTeX
"  put it into ~/.vim/ftplugin/tex/
"  1. In the insert mode, typed any prefix, press <C-l>, you will get a
"  commands or an environment input. Please see s:MapsDict, s:Maps_commands_abbrv
"  and s:Maps_envs_abbrv for the list of abbreviation
"  2. In the insert mode, if you type ^^, it will give ^{} and the cursor
"  inside the curly brace, if you type `/, it will give \frac{}{} and the
"  cursor inside the first curly brace. The behavior is simlar to
"  latex-suite's. Indeed, the TEXIMAP() function is borrowed from the 
"  latex-suite plugin.
"  3. In the insert mode, press <C-i>, type and env name, you will get an env
"  input. See s:KeyWDict for the list.
"  4. I suggest y u do not set "set showmatch" in your vimrc, it will cause a
"  lot delay when typing (),{},[].
"=============================================================================

if exists("g:loaded_teximaps")
	finish
endif
let g:loaded_teximaps = 1

if !exists('g:tex_TEXIMAP')
	let g:tex_TEXIMAP = 1
endif

"{{{1
let s:MapsDict = {
			\ 'align' : "\\begin{align}\<cr><++>&\\\\\<cr>&\<cr>\\end{align}",
			\ 'aligned' : "\\begin{aligned}\<cr><++>&\\\\\<cr>&\<cr>\\end{aligned}",
			\ 'array' : "\\left\<cr>\\begin{array}{<++>}\<cr>\<cr>\\end{array}\<cr>\\right",
			\ 'av' : "\\left|\<++> \\right|",
			\ 'bb' : "\\mathbb{<++>}",
			\ 'bf' : "\\mathbf{<++>}",
			\ 'bk' : "\llbracket <++>\rrbracket",
			\ 'cal' : "\\mathcal{<++>}",
			\ 'cas' : "\\begin{cases}\<cr><++>\<cr>\\end{cases}",
			\ 'cball' : "\\cball",
			\ 'cite' : "\\cite{<++>}",
			\ 'enumerate' : "\\begin{enumerate}\<cr>\\item <++>\<cr>\\end{enumerate}",
			\ 'eqref' : "\\eqref{eq:<++>}",
			\ 'exp' : "\\exp\\left(<++>\\right)",
			\ 'frac' : "\\frac{<++>}{}",
			\ 'frak' : "\\mathfrak{<++>}",
			\ 'figure' :  "\\begin{figure}[H]\<cr>\\centering\<cr>"
			\ ."\\includegraphics[width=\\textwidth]{<++>.eps}\<cr>"
			\ ."\\caption{}\<cr>\\label{fig:}\<cr>\\end{figure}",
			\ 'int' : "\\int_{<++>}^{}",
			\ 'ip' : "\\langle <++> \\rangle",
			\ 'itemize' : "\\begin{itemize}\<cr>\\item <++>\<cr>\\end{itemize}",
			\ 'label' : "\\label{<++>}",
			\ 'lr' : "\\left<++>\\right",
			\ 'minipage'  : "\\begin{minipage}[t]{<++>cm}\<cr>\\end{minipage}",
			\ 'mbox'  : "\\mbox{<++>}",
			\ 'open'  : "\\oball",
			\ 'overline'  : "\\overline{<++>}",
			\ 'real' : "\\mathbb{R}",
			\ 'ref' : "\\ref{<++>}",
			\ 'rn' : "\\mathbb{R}^n",
			\ 'rm' : "\\mathbb{R}^m",
			\ 'r2' : "\\mathbb{R}^2",
			\ 'r3' : "\\mathbb{R}^3",
			\ 'rb' : "\\left(<++>\\right)",
			\ 'sb' : "\\left[<++>\\right]",
			\ 'scr' : "\\mathscr{<++>}",
			\ 'sum'  : "\\sum_{<++>}^{}",
			\ 'suml' : "\\sum\\limits_{<++>}^{}",
			\ 'tabular' : "\\begin{table}\<cr>\\centering\<cr>"
			\ ."\\caption{tab:}\<cr>\\begin{tabular}{<++>}\<cr>\<cr>"
			\ ."\\end{tabular}\<cr>\\label{tab:}\<cr>\\end{table}",
			\ 'text' : "\\text{<++>}",
			\ 'tikzpicture'  : "\\begin{tikzpicture}[thick, scale=2]\<cr><++>"
			\ ."\<cr>\\end{tikzpicture}",
			\ 'tw' : "\\textwidth",
			\ 'vli' : "\\varliminf_{<++>}",
			\ 'vls' : "\\varlimsup_{<++>}",
			\ 've' : "\\varepsilon",
			\ 'vt' : "\\vartheta",
			\ 'vr' : "\\varrho",
			\ 'vp' : "\\varphi",
			\ 'underline' : "\\underline{<++>}",
			\ 'alpha' : "\\alpha",
			\ 'beta' : "\\beta",
			\ 'gamma' : "\\gamma",
			\ 'delta' : "\\delta",
			\ 'epsilon' : "\\epsilon",
			\ 'zeta' : "\\zeta",
			\ 'theta' : "\\theta",
			\ 'kappa' : "\\kappa",
			\ 'lambda' : "\\lambda",
			\ 'sigma' : "\\sigma",
			\ 'upsilon' : "\\upsilon",
			\ 'omega' : "\\omega",
			\ 'Alpha'   : "\\Alpha",
			\ 'Beta'    : "\\Beta",
			\ 'Gamma'   : "\\Gamma",
			\ 'Delta'   : "\\Delta",
			\ 'Epsilon' : "\\Epsilon",
			\ 'Zeta'    : "\\Zeta",
			\ 'Theta'   : "\\Theta",
			\ 'Kappa'   : "\\Kappa",
			\ 'Lambda'  : "\\Lambda",
			\ 'Sigma'   : "\\Sigma",
			\ 'Upsilon' : "\\Upsilon",
			\ 'Omega'   : "\\Omega",
			\ 'Thm'   : "Theorem \\ref{thm:<++>}",
			\ 'Cor'   : "Corollary \\ref{co<++>}",
			\ 'Prop'   : "Proposition \\ref{prop:<++>}",
			\ 'Le'   : "Lemma \\ref{le:<++>}" 
			\ }
"}}}

"{{{1
let s:Maps_commands_abbrv = {
			\ 'a' : 'alpha',
			\ 'b' : 'beta',
			\ 'd' : 'delta',
			\ 'D' : 'Delta',
			\ 'e' : 'epsilon',
			\ 'er' : 'eqref',
			\ 'g' : 'gamma',
			\ 'G' : 'Gamma',
			\ 'k' : 'kappa',
			\ 'l' : 'lambda',
			\ 'L' : 'Lambda',
			\ 'la' : 'label',
			\ 'le' : 'lemma',
			\ 'o' : 'omega',
			\ 'O' : 'Omega',
			\ 'ol' : 'overline',
			\ 'r' : 'real',
			\ 's' : 'sigma',
			\ 'S' : 'Sigma',
			\ 't' : 'theta',
			\ 'T' : 'Theta',
			\ 'tt' : 'text',
			\ 'u' : 'upsilon',
			\ 'ul' : 'underline',
			\ 'U' : 'Upsilon',
			\ 'z' : 'zeta'
			\ }
"}}}

"{{{1
let s:Maps_envs_abbrv = {
			\ 'al' : 'align',
			\ 'ald' : 'aligned',
			\ 'ar' : 'array',
			\ 'athm' : 'algorithm',
			\ 'cor' : 'corollary',
			\ 'conj' : 'conjecture',
			\ 'def' : 'definition',
			\ 'enu' : 'enumerate',
			\ 'eq' : 'equation',
			\ 'eq*' : 'equation*',
			\ 'exa' : 'example',
			\ 'exm' : 'example',
			\ 'exe' : 'exercise',
			\ 'dm' : 'displaymath',
			\ 'fig' : 'figure',
			\ 'ga' : 'gather*',
			\ 'gad' : 'gathered',
			\ 'item' : 'itemize',
			\ 'pf' : 'proof',
			\ 'prob' : 'problem',
			\ 'prop' : 'proposition',
			\ 'ques' : 'question',
			\ 're' : 'remark',
			\ 'sol' : 'solution',
			\ 'thm' : 'theorem',
			\ 'tab' : 'tabular',
			\ 'tikz' : 'tikzpicture'
			\ }
"}}}

let s:Mapsabbrv = extend(s:Maps_commands_abbrv,s:Maps_envs_abbrv)

inoremap <buffer> <C-l>		 <C-r>=<SID>PutEnvironment()<CR>

function! s:PutEnvironment() "{{{1
	let linenum = line(".")
	let colnum = col(".")-1
	let line = getline(".")
	let stcn = colnum
	while stcn > 0
		let startp = strpart(line,stcn-1,1)
		if startp =~ '\W'
			break
		else
		let stcn = stcn - 1
		endif
	endwhile
	let word = strpart(line,stcn,colnum-stcn)
	if word != ''
		if has_key(s:Mapsabbrv,word)  
			let env =  get(s:Mapsabbrv,word)
		else
			let env = word
		endif
		""<C-g>u for an undo point
		return "\<C-g>u\<C-r>=Tex_env_Debug('".word."','".env."')\<cr>"
	endif
endfunction
"}}}

function! Tex_env_Debug(word,env) "{{{
	let bkspc = substitute(a:word, '.', "\<bs>", "g")
	if has_key(s:MapsDict,a:env)
		let rhs = get(s:MapsDict,a:env)
	else
		let rhs= "\\begin{".a:env."}\<cr><++>\<cr>\\end{".a:env."}"
	endif
	let events = PutTextWithMovement(rhs)
	return bkspc.events
endfunction
"}}}

""""%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fun! s:Hash(text) "{{{
	return substitute(a:text, '\([^[:alnum:]]\)',
				\ '\="_".char2nr(submatch(1))."_"', 'g')
endfun
"}}}
function! TEXIMAP(lhs, rhs,...) "{{{1
	let hash = s:Hash(a:lhs)
	let s:Map_tex_{hash} = a:rhs
	let lastLHSChar = a:lhs[strlen(a:lhs)-1]
	let hash = s:Hash(lastLHSChar)
	if !exists("s:LHS_tex_" . hash)
		let s:LHS_tex_{hash} = escape(a:lhs, '\')
	else
		let s:LHS_tex_{hash} = escape(a:lhs, '\') .'\|'.  s:LHS_tex_{hash}
	endif

	" map only the last character of the left-hand side.
	if lastLHSChar == ' '
		let lastLHSChar = '<space>'
	end
	if a:0 > 0
		exe 'inoremap <silent>'
					\ escape(lastLHSChar, '|')
					\ '<C-r>=<SID>LookupCharacter("' .
					\ escape(lastLHSChar, '\|"') .
					\ '","'.a:1.'")<CR>'
	else
		exe 'inoremap <silent>'
					\ escape(lastLHSChar, '|')
					\ '<C-r>=<SID>LookupCharacter("' .
					\ escape(lastLHSChar, '\|"') .
					\ '")<CR>'
	endif
endfunction
"}}}

function! s:LookupCharacter(char,...) "{{{1
	let charHash = s:Hash(a:char)
	let text = strpart(getline("."), 0, col(".")-1) . a:char
	if !exists('lhs') || !exists('rhs')
		let lhs = matchstr(text, "\\C\\V\\(" . s:LHS_tex_{charHash} . "\\)\\$")
		if strlen(lhs) == 0
			return a:char
		else
			let hash = s:Hash(lhs)
			let rhs = s:Map_tex_{hash}
		endif
	endif
	let bs = substitute(strpart(lhs, 1), ".", "\<bs>", "g")
	" \<c-g>u inserts an undo point
	if a:0 > 0
		return a:char . "\<c-g>u\<bs>" . bs . PutTextWithMovement(rhs,a:1)
	else
		return a:char . "\<c-g>u\<bs>" . bs . PutTextWithMovement(rhs)
	endif
endfunction
"}}}

function! PutTextWithMovement(str,...) "{{{1
	if a:0 > 0
		let movement = "\<esc>".a:1."a"
	else
		if a:str =~ '<++>'
			let movement = "\<esc>?<++>\<cr>:call TeX_Outils_RLHI()\<cr>".'"_4s'
		else
			let movement = ""
		endif
	endif
	return a:str.movement
endfunction
"}}}


function! TeX_Outils_RLHI()
	call histdel("/", -1)
	let @/ = histget("/", -1)
endfunction

if g:tex_TEXIMAP
call TEXIMAP("__","_{<++>}")
call TEXIMAP("^^","^{<++>}")
call TEXIMAP("$$","$<++>$")
"call TEXIMAP("{}","{}",'h')
"call TEXIMAP("()","()",'h')
"call TEXIMAP("[]","[]",'h')
call TEXIMAP("()","(<++>)")
call TEXIMAP("[]","[<++>]")
call TEXIMAP("{}","{<++>}")
call TEXIMAP("||","|<++>|")
call TEXIMAP("`8","\\infty")
call TEXIMAP("`9","\\subseteq")
call TEXIMAP("`0","\\supseteq")
call TEXIMAP("`6","\\partial")
call TEXIMAP("`~","\\widetilde{<++>}")
call TEXIMAP("`^","\\widehat{<++>}")
call TEXIMAP('`\',"\\setminus")
call TEXIMAP('`e',"\\emptyset")
call TEXIMAP('\[',"\\[\<cr><++>\<cr>\\]")
call TEXIMAP('\{',"\\{<++>\\}")
call TEXIMAP('\(',"\\(<++>\\)")
call TEXIMAP('`/',"\\frac{<++>}{}")
endif
""""%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
let s:KeyWDict = {
			\ '()' : '\left(<++>\right)',
			\ '[]' : '\left[<++>\right]',
			\ '{}' : '\left\{<++>\right\}',
			\ 'fig' :  "\\begin{figure}[H]\<cr>\\centering\<cr>"
			\ ."\\includegraphics[width=\\textwidth]{<++>}\<cr>\\end{figure}",
			\ 'enu' : "\\begin{enumerate}[label=(\\arabic*)]\<cr>"
			\ ."\\item <++>\<cr>\\end{enumerate}",
			\ '\[' : "\\[<++>\<cr>\\]",
			\ 'ncas' : "\\begin{numcases}{}\<cr><++>\<cr>\\end{numcases}",
			\ 'ilim' : '\varinjlim', 
			\ 'dlim' : '\varprojlim', 
			\ 'injto' : '\hookrightarrow', 
			\ 'wc' : '\rightharpoonup', 
			\ 'uc' : '\rightrightarrows', 
			\ }
inoremap <buffer> <C-i>		 <C-r>=<SID>PutEnv()<CR>
function! s:PutEnv() "{{{1
	let key_word = input('Insert Env: ')
	if key_word == ''
		let events = ''
	elseif has_key(s:KeyWDict,key_word)
		let rhs = get(s:KeyWDict,key_word)
		let events = PutTextWithMovement(rhs)
	elseif has_key(s:Maps_envs_abbrv,key_word)
		let env_name = get(s:Maps_envs_abbrv,key_word)
		let rhs= "\\begin{".env_name."}\<cr><++>\<cr>\\end{".env_name."}"
		let events = PutTextWithMovement(rhs)
	else
		let env_name = key_word
		let rhs= "\\begin{".env_name."}\<cr><++>\<cr>\\end{".env_name."}"
		let events = PutTextWithMovement(rhs)
	end
		return events
endfunction
"}}}


" vim:fdm=marker ff=unix

