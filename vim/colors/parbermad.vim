"=============================================================================
" Vim color scheme file
"      Author: Yangqin Fang
"       Email: fangyq09@gmail.com
" 	  Version: 1.1 
""https://www.w3schools.com/colors/color_tryit.asp?hex=FFF0BA
""http://www.w3school.com.cn/tags/html_ref_colornames.asp
""https://www.ditig.com/256-colors-cheat-sheet
""#FFF0BA,#E4DABE,#E7E4BD
"=============================================================================

function! s:syntax_query() abort
  for id in synstack(line("."), col("."))
    echo synIDattr(id, "name"). ' -> ' . synIDattr(synIDtrans(id), 'name')
  endfor
endfunction
command! SyntaxQuery call s:syntax_query()

set bg=light
hi clear
if exists("syntax_on")
	syntax reset
endif

let colors_name = "parbermad"

"hi Normal		guifg=#000000 guibg=#E4DABE		ctermfg=0 ctermbg=222
hi Normal		guifg=#000000 guibg=#FFF0BA		ctermfg=0 ctermbg=230
hi ErrorMsg		guifg=red guibg=#ffffff		ctermfg=9 ctermbg=15
hi Error		guifg=red guibg=#ffffff		ctermfg=9 ctermbg=15
hi Visual		guifg=#8080ff guibg=fg		gui=reverse		ctermfg=63 ctermbg=fg cterm=reverse
hi VisualNOS	guifg=#8080ff guibg=fg		gui=reverse,underline	ctermfg=63 ctermbg=fg cterm=reverse,underline
hi Todo			guifg=blue guibg=darkgoldenrod		ctermfg=12	ctermbg=136
hi Search		guifg=black guibg=gold			ctermfg=0 ctermbg=178 cterm=underline term=underline
hi IncSearch	guifg=#b0ffff guibg=#2050d0		ctermfg=159 ctermbg=27
hi MatchParen   guifg=Black guibg=CadetBlue ctermfg=0   ctermbg=72	
hi SpecialKey		guifg=darkgreen			ctermfg=22
hi Directory		guifg=deeppink			ctermfg=197
hi Title				guifg=magenta gui=bold ctermfg=201 cterm=bold
hi WarningMsg		guifg=darkred			ctermfg=52
hi WildMenu			guifg=yellow guibg=black ctermfg=11 ctermbg=0
hi ModeMsg			guifg=#22cce2		ctermfg=44
hi MoreMsg			guifg=darkgreen	ctermfg=22
hi Question			guifg=green gui=none ctermfg=2 cterm=none
hi NonText			guifg=#0030ff		ctermfg=21
hi StatusLine 	guifg=black	guibg=gold	gui=none    ctermfg=0 ctermbg=178 term=none cterm=none
hi StatusLineNC		guifg=black guibg=Grey42 gui=none		ctermfg=0 ctermbg=42 term=none cterm=none
hi VertSplit		guifg=black guibg=Grey42 gui=none		ctermfg=0 ctermbg=42 term=none cterm=none
hi Folded  	guifg=black	guibg=darksalmon	ctermfg=0 ctermbg=209 cterm=bold term=bold
hi FoldColumn		guifg=Grey guibg=#000040			ctermfg=8 ctermbg=17 cterm=bold term=bold
hi LineNr			guifg=red			ctermfg=9 
hi DiffAdd			guibg=LightGreen	ctermbg=119 
hi DiffChange		guibg=darkmagenta ctermbg=90 
hi DiffDelete		gui=bold guifg=Blue guibg=DarkCyan ctermfg=12 ctermbg=36 
hi DiffText			cterm=bold  gui=bold 
hi Cursor      guifg=#ffffff guibg=#6600CC ctermfg=15 ctermbg=55
hi lCursor		 guifg=#ffffff guibg=#000000 ctermfg=15 ctermbg=0
hi CursorLine  guibg=peachpuff ctermbg=223 
hi CursorIM    guifg=#000000	guibg=#8A4C98 ctermfg=0  ctermbg=53	
hi Comment	guifg=black guibg=#F5DEB3 ctermfg=0  ctermbg=255	
hi String		guifg=DarkGreen gui=bold ctermfg=22  cterm=bold
hi Special	guifg=BlueViolet gui=bold ctermfg=57  cterm=bold
hi Identifier	guifg=brown gui=none ctermfg=215  cterm=bold
hi Statement	guifg=#5555ff gui=bold ctermfg=63  cterm=bold
hi PreProc		guifg=green3 gui=bold ctermfg=34  cterm=bold
hi PreCondit	guifg=green4 gui=bold ctermfg=28  cterm=bold
hi type				guifg=magenta gui=bold ctermfg=201  cterm=bold
hi Label      guifg=Olive gui=bold ctermfg=3  cterm=bold
hi Operator   guifg=brown gui=bold ctermfg=215  cterm=bold
hi Number     guifg=red gui=bold ctermfg=9  cterm=bold
hi Constant		guifg=#ff88d3 gui=bold ctermfg=170  cterm=bold
hi Function   guifg=DarkOliveGreen  gui=bold  ctermfg=107  cterm=bold
hi IO					guifg=red gui=bold ctermfg=9  cterm=bold
hi Communicator		guibg=yellow guifg=black gui=none ctermfg=0 ctermbg=11 term=none
hi UnitHeader			guibg=lightblue guifg=black gui=bold  ctermfg=0 ctermbg=27 term=bold
hi Macro        guibg=ForestGreen ctermbg=64
hi Keyword      	guifg=orangered ctermfg=202
hi Underlined	gui=underline cterm=underline term=underline
hi Ignore	guifg=bg ctermfg=bg
hi colorcolumn 	 guibg=#999933 ctermbg=3
hi Conceal  guifg=green4 guibg=peachpuff ctermfg=28 ctermbg=223 cterm=bold gui=bold
hi Delimiter		guifg=DarkCyan gui=bold ctermfg=36
hi SpellBad	gui=undercurl,bold,italic guifg=Purple4 guibg=bg ctermfg=54 ctermbg=bg cterm=underline,bold,italic 

hi texSectionMarker		guifg=darkgoldenrod	    gui=bold   ctermfg=136 cterm=bold
hi texSection		      guifg=Olive	          gui=bold,underline ctermfg=100 cterm=bold
hi texSectionName			guifg=Black             gui=bold ctermfg=0
hi texInputFile				guifg=ForestGreen       ctermfg=64
hi texCmdArgs			    guifg=SkyBlue           gui=bold ctermfg=117
hi texInputFileOpt			guifg=#999933           ctermfg=3
hi texType				      guifg=DarkSlateGray     ctermfg=106
hi texTypeStyle		    guifg=DarkGreen         ctermfg=22
hi texMath				      guifg=Red4              gui=bold ctermfg=124 cterm=bold
hi texStatement 				guifg=Blue              ctermfg=12
hi texString				    guifg=Blue4             ctermfg=19
hi texSpecialChar			guifg=DodgerBlue        ctermfg=27
hi texRefZone					guifg=DeepPink2		      gui=bold ctermfg=197 cterm=bold
hi texCite							guifg=DeepPink4         ctermfg=53
hi texGreek				    guifg=Green4            gui=bold	ctermfg=28 cterm=bold
hi texMathDelim		    guifg=MidnightBlue      ctermfg=4
hi texDef					    guifg=DodgerBlue        ctermfg=27
hi texMathSymbol 	    guifg=NavyBlue          ctermfg=17
hi texMathOper			    guifg=Purple            ctermfg=5
hi texRefOption				guifg=HotPink4          ctermfg=132
hi texMathMatcher  	  guifg=DarkOrange3       ctermfg=130


