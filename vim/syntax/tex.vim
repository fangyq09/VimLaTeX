" Vim syntax file
" Language:	TeX
" Maintainer:	Charles E. Campbell <NdrchipO@ScampbellPfamily.AbizM>
" Last Change:	Mar 07, 2016
" Version:	93
" URL:		http://www.drchip.org/astronaut/vim/index.html#SYNTAX_TEX
"
" Notes: {{{1
"
" 1. If you have a \begin{verbatim} that appears to overrun its boundaries,
"    use %stopzone.
"
" 2. Run-on equations ($..$ and $$..$$, particularly) can also be stopped
"    by suitable use of %stopzone.
"
" 3. If you have a slow computer, you may wish to modify
"
"	syn sync maxlines=200
"	syn sync minlines=50
"
"    to values that are more to your liking.
"
" 4. There is no match-syncing for $...$ and $$...$$; hence large
"    equation blocks constructed that way may exhibit syncing problems.
"    (there's no difference between begin/end patterns)
"
" 5. If you have the variable "g:tex_no_error" defined then none of the
"    lexical error-checking will be done.
"
"    ie. let g:tex_no_error=1
"
" 6. Please see  :help latex-syntax  for information on
"      syntax folding           :help tex-folding
"      spell checking           :help tex-nospell
"      commands and mathzones   :help tex-runon
"      new command highlighting :help tex-morecommands
"      error highlighting       :help tex-error
"      new math groups          :help tex-math
"      new styles               :help tex-style
"      using conceal mode       :help tex-conceal

" Version Clears: {{{1
" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif
let s:keepcpo= &cpo
set cpo&vim
scriptencoding utf-8

" Define the default highlighting. {{{1
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_tex_syntax_inits")
 let did_tex_syntax_inits = 1
 if version < 508
  command -nargs=+ HiLink hi link <args>
 else
  command -nargs=+ HiLink hi def link <args>
 endif
endif


" Determine whether or not to use "*.sty" mode {{{1
" The user may override the normal determination by setting
"   g:tex_stylish to 1      (for    "*.sty" mode)
"    or to           0 else (normal "*.tex" mode)
" or on a buffer-by-buffer basis with b:tex_stylish
let s:extfname=expand("%:e")
if exists("g:tex_stylish")
 let b:tex_stylish= g:tex_stylish
elseif !exists("b:tex_stylish")
 if s:extfname == "sty" || s:extfname == "cls" || s:extfname == "clo" || s:extfname == "dtx" || s:extfname == "ltx"
  let b:tex_stylish= 1
 else
  let b:tex_stylish= 0
 endif
endif

" (La)TeX keywords: uses the characters 0-9,a-z,A-Z,192-255 only... {{{1
" but _ is the only one that causes problems.
" One may override this iskeyword setting by providing
" g:tex_isk
if exists("g:tex_isk")
 exe "setlocal isk=".g:tex_isk
elseif !has("patch-7.4.1141")
 setl isk=48-57,a-z,A-Z,192-255
else
 syn iskeyword 48-57,a-z,A-Z,192-255
endif
if b:tex_stylish
  setlocal isk+=@-@
endif
if exists("g:tex_no_error") && g:tex_no_error
 let s:tex_no_error= 1
else
 let s:tex_no_error= 0
endif
if exists("g:tex_comment_nospell") && g:tex_comment_nospell
 let s:tex_comment_nospell= 1
else
 let s:tex_comment_nospell= 0
endif
if exists("g:tex_nospell") && g:tex_nospell
 let s:tex_nospell = 1
else
 let s:tex_nospell = 0
endif

" Clusters: {{{1
" --------
syn cluster texCmdGroup			contains=texCmdBody,texComment,texDefParm,texDelimiter,texDocType,texInput,texLength,texLigature,texMathDelim,texMathOper,texNewCmd,texNewEnv,texRefZone,texSection,texBeginEnd,texBeginEndName,texSpecialChar,texStatement,texString,texTypeSize,texTypeStyle
if !s:tex_no_error
 syn cluster texCmdGroup		add=texMathError
endif
syn cluster texEnvGroup			contains=texMatcher,texMathDelim,texSpecialChar,texStatement
syn cluster texFoldGroup		contains=texAccent,texBadMath,texComment,texDefCmd,texDelimiter,texDocType,texInput,texInputFile,texLength,texLigature,texMatcher,texMathZoneV,texMathZoneW,texMathZoneX,texMathZoneY,texMathZoneZ,texNewCmd,texNewEnv,texOnlyMath,texOption,texParen,texRefZone,texSection,texBeginEnd,texSectionZone,texSpaceCode,texSpecialChar,texStatement,texString,texTypeSize,texTypeStyle,texZone,@texMathZones,texTitle,texAbstract,texBoldStyle,texItalStyle,texNoSpell,texEnvFold,texBibFold,texCommentFold
syn cluster texBoldGroup		contains=texAccent,texBadMath,texComment,texDefCmd,texDelimiter,texDocType,texInput,texInputFile,texLength,texLigature,texMatcher,texMathZoneV,texMathZoneW,texMathZoneX,texMathZoneY,texMathZoneZ,texNewCmd,texNewEnv,texOnlyMath,texOption,texParen,texRefZone,texSection,texBeginEnd,texSectionZone,texSpaceCode,texSpecialChar,texStatement,texString,texTypeSize,texTypeStyle,texZone,@texMathZones,texTitle,texAbstract,texBoldStyle,texBoldItalStyle,texNoSpell
syn cluster texItalGroup		contains=texAccent,texBadMath,texComment,texDefCmd,texDelimiter,texDocType,texInput,texInputFile,texLength,texLigature,texMatcher,texMathZoneV,texMathZoneW,texMathZoneX,texMathZoneY,texMathZoneZ,texNewCmd,texNewEnv,texOnlyMath,texOption,texParen,texRefZone,texSection,texBeginEnd,texSectionZone,texSpaceCode,texSpecialChar,texStatement,texString,texTypeSize,texTypeStyle,texZone,@texMathZones,texTitle,texAbstract,texItalStyle,texItalBoldStyle,texNoSpell
if !s:tex_nospell
 syn cluster texMatchGroup		contains=texAccent,texBadMath,texComment,texDefCmd,texDelimiter,texDocType,texInput,texLength,texLigature,texMatcher,texNewCmd,texNewEnv,texOnlyMath,texParen,texRefZone,texSection,texSpecialChar,texStatement,texString,texTypeSize,texTypeStyle,texZone,texInputFile,texOption,@Spell
 syn cluster texStyleGroup		contains=texAccent,texBadMath,texComment,texDefCmd,texDelimiter,texDocType,texInput,texLength,texLigature,texNewCmd,texNewEnv,texOnlyMath,texParen,texRefZone,texSection,texSpecialChar,texStatement,texString,texTypeSize,texTypeStyle,texZone,texInputFile,texOption,texStyleStatement,@Spell,texStyleMatcher
else
 syn cluster texMatchGroup		contains=texAccent,texBadMath,texComment,texDefCmd,texDelimiter,texDocType,texInput,texLength,texLigature,texMatcher,texNewCmd,texNewEnv,texOnlyMath,texParen,texRefZone,texSection,texSpecialChar,texStatement,texString,texTypeSize,texTypeStyle,texZone,texInputFile,texOption
 syn cluster texStyleGroup		contains=texAccent,texBadMath,texComment,texDefCmd,texDelimiter,texDocType,texInput,texLength,texLigature,texNewCmd,texNewEnv,texOnlyMath,texParen,texRefZone,texSection,texSpecialChar,texStatement,texString,texTypeSize,texTypeStyle,texZone,texInputFile,texOption,texStyleStatement,texStyleMatcher
endif
syn cluster texPreambleMatchGroup	contains=texAccent,texBadMath,texComment,texDefCmd,texDelimiter,texDocType,texInput,texLength,texLigature,texMatcher,texNewCmd,texNewEnv,texOnlyMath,texParen,texRefZone,texSection,texSpecialChar,texStatement,texString,texTitle,texTypeSize,texTypeStyle,texZone,texInputFile,texOption,texMathZoneZ
syn cluster texRefGroup			contains=texMatcher,texComment,texDelimiter
if !exists("g:tex_no_math")
 syn cluster texPreambleMatchGroup	contains=texAccent,texBadMath,texComment,texDefCmd,texDelimiter,texDocType,texInput,texLength,texLigature,texMatcher,texNewCmd,texNewEnv,texOnlyMath,texParen,texRefZone,texSection,texSpecialChar,texStatement,texString,texTitle,texTypeSize,texTypeStyle,texZone,texInputFile,texOption,texMathZoneZ
 syn cluster texMathZones		contains=texMathZoneV,texMathZoneW,texMathZoneX,texMathZoneY,texMathZoneZ
 syn cluster texMatchGroup		add=@texMathZones
 syn cluster texMathDelimGroup		contains=texMathDelimBad,texMathDelimKey,texMathDelimSet1,texMathDelimSet2
 syn cluster texMathMatchGroup		contains=@texMathZones,texComment,texDefCmd,texDelimiter,texDocType,texInput,texLength,texLigature,texMathDelim,texMathMatcher,texMathOper,texNewCmd,texNewEnv,texRefZone,texSection,texSpecialChar,texStatement,texString,texTypeSize,texTypeStyle,texZone
 syn cluster texMathZoneGroup		contains=texComment,texDelimiter,texLength,texMathDelim,texMathMatcher,texMathOper,texMathSymbol,texMathText,texRefZone,texSpecialChar,texStatement,texTypeSize,texTypeStyle
 if !s:tex_no_error
  syn cluster texMathMatchGroup		add=texMathError
  syn cluster texMathZoneGroup		add=texMathError
 endif
 syn cluster texMathZoneGroup		add=@NoSpell
 " following used in the \part \chapter \section \subsection \subsubsection
 " \paragraph \subparagraph \author \title highlighting
 syn cluster texDocGroup		contains=texPartZone,@texPartGroup
 syn cluster texPartGroup		contains=texChapterZone,texSectionZone,texParaZone
 syn cluster texChapterGroup		contains=texSectionZone,texParaZone
 syn cluster texSectionGroup		contains=texSubSectionZone,texParaZone
 syn cluster texSubSectionGroup		contains=texSubSubSectionZone,texParaZone
 syn cluster texSubSubSectionGroup	contains=texParaZone
 syn cluster texParaGroup		contains=texSubParaZone
  syn cluster texMathZoneGroup		add=texGreek,texMathScripts,texMathScriptArg,texMathSymbol
  syn cluster texMathMatchGroup		add=texGreek,texMathScripts,texMathScriptArg,texMathSymbol
endif

" Try to flag {} and () mismatches: {{{1

syn match texMathOper		"[=<>+-/]" contained

" Math sub/super scripts
syn match texMathScripts contained '[_^]'
	    \ nextgroup=texMathScriptArg skipwhite skipempty
syn region texMathScriptArg contained transparent
	    \ matchgroup=texMathScripts start='{' end='}'
	    \ contains=@texMathZoneGroup
if !s:tex_no_error
  syn region texMatcher		matchgroup=Delimiter
	\ start="{" skip="\\\\\|\\[{}]"	end="}"	
	\ transparent contains=@texMatchGroup,texError
  syn region texMatcher		matchgroup=Delimiter
	\ start="\["				end="]"	
	\ transparent contains=@texMatchGroup,texError,@NoSpell
else
  syn region texMatcher		matchgroup=Delimiter
	\ start="{" skip="\\\\\|\\[{}]"	end="}"	
	\ transparent contains=@texMatchGroup
  syn region texMatcher		matchgroup=Delimiter
	\ start="\["				end="]"	
	\ transparent contains=@texMatchGroup
endif
if !s:tex_nospell
  syn region texParen	start="(" end=")" transparent contains=@texMatchGroup,@Spell
else
  syn region texParen	start="(" end=")" transparent contains=@texMatchGroup
endif
if !s:tex_no_error
 syn match  texError		"[}\])]"
endif
if !exists("g:tex_no_math")
  if !s:tex_no_error
    syn match  texMathError	"}"	contained
  endif
  syn region texMathMatcher	matchgroup=Delimiter
	\ start="{"         
	\ skip="\%(\\\\\)*\\}"  
	\ end="}"
	\ end="%stopzone\>"	contained contains=@texMathMatchGroup
endif

" TeX/LaTeX keywords: {{{1
" Instead of trying to be All Knowing, I just match \..alphameric..
" Note that *.tex files may not have "@" in their \commands
if exists("g:tex_tex") || b:tex_stylish
  syn match texStatement	"\\[a-zA-Z@]\+"
else
  syn match texStatement	"\\\a\+"
  if !s:tex_no_error
   syn match texError		"\\\a*@[a-zA-Z@]*"
  endif
endif

" TeX/LaTeX delimiters: {{{1
syn match texDelimiter		"&"
syn match texDelimiter		"\\\\"

" Tex/Latex Options: {{{1
syn match texOption		"[^\\]\zs#\d\+\|^#\d\+"


" \begin{}/\end{} section markers: {{{1
syn match  texBeginEnd		"\\begin\>\|\\end\>" nextgroup=texBeginEndName
  syn region texBeginEndName		matchgroup=Delimiter	start="{"		end="}"	contained	nextgroup=texBeginEndModifier	contains=texComment
  syn region texBeginEndModifier	matchgroup=Delimiter	start="\["		end="]"	contained	contains=texComment,@NoSpell

" \documentclass, \documentstyle, \usepackage: {{{1
syn match  texDocType		"\\documentclass\>\|\\documentstyle\>\|\\usepackage\>" nextgroup=texBeginEndName,texDocTypeArgs
  syn region texDocTypeArgs	matchgroup=Delimiter start="\[" end="]"			contained	nextgroup=texBeginEndName	contains=texComment,@NoSpell


" TeX input: {{{1
syn match texInput		"\\input\s\+[a-zA-Z/.0-9_^]\+"hs=s+7				contains=texStatement
syn match texInputFile		"\\include\(graphics\|list\|pdf\)\=\(\[.\{-}\]\)\=\s*{.\{-}}"	contains=texStatement,texInputCurlies,texInputFileOpt
syn match texInputFile		"\\\(epsfig\|input\|usepackage\)\s*\(\[.*\]\)\={.\{-}}"		contains=texStatement,texInputCurlies,texInputFileOpt
syn match texInputCurlies	"[{}]"								contained
 syn region texInputFileOpt	matchgroup=Delimiter start="\[" end="\]"			contained	contains=texComment

" Type Styles (LaTeX 2.09): {{{1
syn match texTypeStyle		"\\rm\>"
syn match texTypeStyle		"\\em\>"
syn match texTypeStyle		"\\bf\>"
syn match texTypeStyle		"\\it\>"
syn match texTypeStyle		"\\sl\>"
syn match texTypeStyle		"\\sf\>"
syn match texTypeStyle		"\\sc\>"
syn match texTypeStyle		"\\tt\>"

" Type Styles: attributes, commands, families, etc (LaTeX2E): {{{1
syn match texTypeStyle		"\\textmd\>"
syn match texTypeStyle		"\\textrm\>"
syn match texTypeStyle		"\\textsc\>"
syn match texTypeStyle		"\\textsf\>"
syn match texTypeStyle		"\\textsl\>"
syn match texTypeStyle		"\\texttt\>"
syn match texTypeStyle		"\\textup\>"
syn match texTypeStyle		"\\emph\>"

syn match texTypeStyle		"\\mathbb\>"
syn match texTypeStyle		"\\mathbf\>"
syn match texTypeStyle		"\\mathcal\>"
syn match texTypeStyle		"\\mathfrak\>"
syn match texTypeStyle		"\\mathit\>"
syn match texTypeStyle		"\\mathnormal\>"
syn match texTypeStyle		"\\mathrm\>"
syn match texTypeStyle		"\\mathsf\>"
syn match texTypeStyle		"\\mathtt\>"

syn match texTypeStyle		"\\rmfamily\>"
syn match texTypeStyle		"\\sffamily\>"
syn match texTypeStyle		"\\ttfamily\>"

syn match texTypeStyle		"\\itshape\>"
syn match texTypeStyle		"\\scshape\>"
syn match texTypeStyle		"\\slshape\>"
syn match texTypeStyle		"\\upshape\>"

syn match texTypeStyle		"\\bfseries\>"
syn match texTypeStyle		"\\mdseries\>"

" Some type sizes: {{{1
syn match texTypeSize		"\\tiny\>"
syn match texTypeSize		"\\scriptsize\>"
syn match texTypeSize		"\\footnotesize\>"
syn match texTypeSize		"\\small\>"
syn match texTypeSize		"\\normalsize\>"
syn match texTypeSize		"\\large\>"
syn match texTypeSize		"\\Large\>"
syn match texTypeSize		"\\LARGE\>"
syn match texTypeSize		"\\huge\>"
syn match texTypeSize		"\\Huge\>"

" Spacecodes (TeX'isms): {{{1
" \mathcode`\^^@="2201  \delcode`\(="028300  \sfcode`\)=0 \uccode`X=`X  \lccode`x=`x
syn match texSpaceCode		"\\\(math\|cat\|del\|lc\|sf\|uc\)code`"me=e-1 nextgroup=texSpaceCodeChar
syn match texSpaceCodeChar    "`\\\=.\(\^.\)\==\(\d\|\"\x\{1,6}\|`.\)"	contained

" Sections, subsections, etc: {{{1

syn region texPartZone	matchgroup=texSection
      \ start='\\part\>'			
      \ end='\ze\s*\\\%(part\>\|end\s*{\s*document\s*}\)'
      \ end='\ze\s*\\\%(bibliography\|addcontentsline\|begin\s*{\s*thebibliography\s*}\)\@='
      \ contains=@texFoldGroup,@texPartGroup,@Spell
syn region texChapterZone	matchgroup=texSection
      \ start='\\chapter\>'		
      \ end='\ze\s*\\\%(chapter\>\|part\>\|end\s*{\s*document\s*}\)'
      \ end='\ze\s*\\\%(bibliography\|addcontentsline\|begin\s*{\s*thebibliography\s*}\)\@='
      \ contains=@texFoldGroup,@texChapterGroup,@Spell
syn region texSectionZone	matchgroup=texSection 
      \ start='\\section\>'		 
      \ end='\ze\s*\\\%(section\>\|chapter\>\|part\>\|end\s*{\s*document\s*}\)'
      \ end='\ze\s*\\\%(bibliography\|addcontentsline\|begin\s*{\s*thebibliography\s*}\)\@='
      \ contains=@texFoldGroup,@texSectionGroup,@Spell
syn region texSubSectionZone	matchgroup=texSection
      \ start='\\subsection\>'		 
      \ end='\ze\s*\\\%(\%(sub\)\=section\>\|chapter\>\|part\>\|end\s*{\s*document\s*}\)'
      \ end='\ze\s*\\\%(bibliography\|addcontentsline\|begin\s*{\s*thebibliography\s*}\)\@='
      \ contains=@texFoldGroup,@texSubSectionGroup,@Spell
syn region texSubSubSectionZone	matchgroup=texSection 
      \ start='\\subsubsection\>'	
      \ end='\ze\s*\\\%(\%(sub\)\{,2}section\>\|chapter\>\|part\>\|end\s*{\s*document\s*}\)'
      \ end='\ze\s*\\\%(bibliography\|addcontentsline\|begin\s*{\s*thebibliography\s*}\)\@='
      \ contains=@texFoldGroup,@texSubSubSectionGroup,@Spell
syn region texTitle		matchgroup=texSection
      \ start='\\\%(author\|title\)\>\s*{'
      \ end='}'
      \ contains=@texFoldGroup,@Spell
syn region texAbstract		matchgroup=texSection
      \ start='\\begin\s*{\s*abstract\s*}' 
      \ end='\\end\s*{\s*abstract\s*}'
      \ contains=@texFoldGroup,@Spell


" Bad Math (mismatched): {{{1
if !exists("g:tex_no_math") && !s:tex_no_error
  syn match texBadMath		"\\end\s*{\s*\(array\|gathered\|bBpvV]matrix\|split\|smallmatrix\)\s*}"
  syn match texBadMath		"\\end\s*{\s*\(align\|displaymath\|eqnarray\|equation\|flalign\|gather\|math\|multline\)\*\=\s*}"
  syn match texBadMath		"\\[\])]"
endif

" Math Zones: {{{1
 " TexNewMathZone: function creates a mathzone with the given suffix and mathzone name. {{{2
 "                 Starred forms are created if starform is true.  Starred
 "                 forms have syntax group and synchronization groups with a
 "                 "S" appended.  Handles: cluster, syntax, sync, and HiLink.
 fun! TexNewMathZone(sfx,mathzone,starform)
   let grpname  = "texMathZone".a:sfx
   let syncname = "texSyncMathZone".a:sfx
   exe "syn cluster texMathZones add=".grpname
    exe 'syn region '.grpname.' start='."'".'\\begin\s*{\s*'.a:mathzone.'\s*}'."'".' end='."'".'\\end\s*{\s*'.a:mathzone.'\s*}'."'".' keepend contains=@texMathZoneGroup'
    exe 'syn sync match '.syncname.' grouphere '.grpname.' "\\begin\s*{\s*'.a:mathzone.'\*\s*}"'
    exe 'syn sync match '.syncname.' grouphere '.grpname.' "\\begin\s*{\s*'.a:mathzone.'\*\s*}"'
   exe 'hi def link '.grpname.' texMath'
   if a:starform
    let grpname  = "texMathZone".a:sfx.'S'
    let syncname = "texSyncMathZone".a:sfx.'S'
    exe "syn cluster texMathZones add=".grpname
     exe 'syn region '.grpname.' start='."'".'\\begin\s*{\s*'.a:mathzone.'\*\s*}'."'".' end='."'".'\\end\s*{\s*'.a:mathzone.'\*\s*}'."'".' keepend contains=@texMathZoneGroup'
     exe 'syn sync match '.syncname.' grouphere '.grpname.' "\\begin\s*{\s*'.a:mathzone.'\*\s*}"'
     exe 'syn sync match '.syncname.' grouphere '.grpname.' "\\begin\s*{\s*'.a:mathzone.'\*\s*}"'
    exe 'hi def link '.grpname.' texMath'
   endif
 endfun

 " Standard Math Zones: {{{2
 call TexNewMathZone("A","align",1)
 call TexNewMathZone("B","alignat",1)
 call TexNewMathZone("C","displaymath",1)
 call TexNewMathZone("D","eqnarray",1)
 "call TexNewMathZone("E","equation",1)
 "call TexNewMathZone("F","flalign",1)
 "call TexNewMathZone("G","gather",1)
 "call TexNewMathZone("H","math",1)
 "call TexNewMathZone("I","multline",1)
 "call TexNewMathZone("J","subequations",0)
 "call TexNewMathZone("K","xalignat",1)
 "call TexNewMathZone("L","xxalignat",0)

 " Inline Math Zones: {{{2
   syn region texMathZoneV	matchgroup=Special
	 \ start="\\("			matchgroup=Special
	 \ end="\\)\|%stopzone\>"	keepend contains=@texMathZoneGroup
   syn region texMathZoneW	matchgroup=Special
	 \ start="\\\["			matchgroup=Special
	 \ end="\\]\|%stopzone\>"	keepend contains=@texMathZoneGroup
   syn region texMathZoneX	matchgroup=Special
	 \ start="\$"
	 \ skip="\%(\\\\\)*\\\$"	matchgroup=Special
	 \ end="\$"
	 \ end="%stopzone\>"		contains=@texMathZoneGroup
   syn region texMathZoneY	matchgroup=Special
	 \ start="\$\$" 	matchgroup=Special
	 \ end="\$\$"
	 \ end="%stopzone\>"	keepend	contains=@texMathZoneGroup
  syn region texMathZoneZ	matchgroup=texStatement 
	\ start="\\ensuremath\s*{"	matchgroup=texStatement	
	\ end="}"	
	\ end="%stopzone\>"	contains=@texMathZoneGroup



 " Text Inside Math Zones: {{{2
  if !exists("g:tex_nospell") || !g:tex_nospell
   syn region texMathText matchgroup=texStatement start='\\\(\(inter\)\=text\|mbox\)\s*{'	end='}'	contains=@texFoldGroup,@Spell
  else
   syn region texMathText matchgroup=texStatement start='\\\(\(inter\)\=text\|mbox\)\s*{'	end='}'	contains=@texFoldGroup
  endif


" ---------------------------------------------------------------------
 " \left..something.. and \right..something.. support: {{{2
  syn match   texMathDelim	contained		"\\\(left\|right\)\>"	skipwhite nextgroup=texMathDelimSet1,texMathDelimSet2,texMathDelimBad
  syn match   texMathDelim	contained		"\\[bB]igg\=[lr]\=\>"	skipwhite nextgroup=texMathDelimSet1,texMathDelimSet2,texMathDelimBad
  syn match   texMathDelimSet2	contained	"\\"		nextgroup=texMathDelimKey,texMathDelimBad
  syn match   texMathDelimSet1	contained	"[<>()[\]|/.]\|\\[{}|]"
  syn keyword texMathDelimKey	contained	backslash       lceil           lVert           rgroup          uparrow
  syn keyword texMathDelimKey	contained	downarrow       lfloor          rangle          rmoustache      Uparrow
  syn keyword texMathDelimKey	contained	Downarrow       lgroup          rbrace          rvert           updownarrow
  syn keyword texMathDelimKey	contained	langle          lmoustache      rceil           rVert           Updownarrow
  syn keyword texMathDelimKey	contained	lbrace          lvert           rfloor
 syn match   texMathDelim	contained		"\\\(left\|right\)arrow\>\|\<\([aA]rrow\|brace\)\=vert\>"
 syn match   texMathDelim	contained		"\\lefteqn\>"

" Special TeX characters  ( \$ \& \% \# \{ \} \_ \S \P ) : {{{1
syn match texSpecialChar	"\\[$&%#{}_]"
if b:tex_stylish
  syn match texSpecialChar	"\\[SP@][^a-zA-Z@]"me=e-1
else
  syn match texSpecialChar	"\\[SP@]\A"me=e-1
endif
syn match texSpecialChar	"\\\\"
if !exists("g:tex_no_math")
 syn match texOnlyMath		"[_^]"
endif
syn match texSpecialChar	"\^\^[0-9a-f]\{2}\|\^\^\S"

" Comments: {{{1
"    Normal TeX LaTeX     :   %....
"    Documented TeX Format:  ^^A...	-and-	leading %s (only)
if !s:tex_comment_nospell
 syn cluster texCommentGroup	contains=texTodo,@Spell
else
 syn cluster texCommentGroup	contains=texTodo,@NoSpell
endif
syn case ignore
syn keyword texTodo		contained		combak	fixme	todo	xxx
syn case match
if s:extfname == "dtx"
 syn match texComment		"\^\^A.*$"	contains=@texCommentGroup
 syn match texComment		"^%\+"		contains=@texCommentGroup
else
 syn match texComment		"%.*$"			contains=@texCommentGroup
 syn region texNoSpell		contained	matchgroup=texComment start="%\s*nospell\s*{"	end="%\s*nospell\s*}"	contains=@texFoldGroup,@NoSpell
endif

" Separate lines used for verb` and verb# so that the end conditions {{{1
" will appropriately terminate.
" If g:tex_verbspell exists, then verbatim texZones will permit spellchecking there.
if exists("g:tex_verbspell") && g:tex_verbspell
  syn region texZone		start="\\begin{[vV]erbatim}"
	\ end="\\end{[vV]erbatim}\|%stopzone\>"	contains=@Spell
  " listings package:
  syn region texZone		start="\\begin{lstlisting}"	
	\ end="\\end{lstlisting}\|%stopzone\>"	contains=@Spell
  if b:tex_stylish
    syn region texZone		start="\\verb\*\=\z([^\ta-zA-Z@]\)"
	  \ end="\z1\|%stopzone\>"			contains=@Spell
  else
    syn region texZone		start="\\verb\*\=\z([^\ta-zA-Z]\)"
	  \ end="\z1\|%stopzone\>"			contains=@Spell
  endif
else
  syn region texZone		start="\\begin{[vV]erbatim}"	
	\ end="\\end{[vV]erbatim}\|%stopzone\>"
  " listings package:
  syn region texZone		start="\\begin{lstlisting}"	
	\ end="\\end{lstlisting}\|%stopzone\>"
  if b:tex_stylish
    syn region texZone  start="\\verb\*\=\z([^\ta-zA-Z@]\)" end="\z1\|%stopzone\>"
  else
    syn region texZone  start="\\verb\*\=\z([^\ta-zA-Z]\)" end="\z1\|%stopzone\>"
  endif
endif

" Tex Reference Zones: {{{1
  syn region texZone		matchgroup=texStatement start="@samp{"		
	\ end="}\|%stopzone\>"	contains=@texRefGroup
  syn region texRefZone		matchgroup=texStatement start="\\nocite{"	
	\ end="}\|%stopzone\>"	contains=@texRefGroup
  syn region texRefZone		matchgroup=texStatement start="\\bibliography{"	
	\ end="}\|%stopzone\>"	contains=@texRefGroup
  syn region texRefZone		matchgroup=texStatement start="\\label{"
	\ end="}\|%stopzone\>"	contains=@texRefGroup
  syn region texRefZone		matchgroup=texStatement start="\\\(page\|eq\)ref{"
	\ end="}\|%stopzone\>"	contains=@texRefGroup
  syn region texRefZone		matchgroup=texStatement start="\\v\=ref{"	
	\ end="}\|%stopzone\>"	contains=@texRefGroup
  syn region texRefOption	contained	matchgroup=Delimiter start='\[' end=']'	contains=@texRefGroup,texRefZone	nextgroup=texRefOption,texCite
  syn region texCite		contained	matchgroup=Delimiter start='{' end='}'	contains=@texRefGroup,texRefZone,texCite
syn match  texRefZone	'\\cite\%([tp]\*\=\)\=' nextgroup=texRefOption,texCite

" Handle newcommand, newenvironment : {{{1
syn match  texNewCmd				"\\\(re\)\=newcommand\>"			nextgroup=texCmdName skipwhite skipnl
  syn region texCmdName contained matchgroup=Delimiter start="{"rs=s+1  end="}"		nextgroup=texCmdArgs,texCmdBody skipwhite skipnl
  syn region texCmdArgs contained matchgroup=Delimiter start="\["rs=s+1 end="]"		nextgroup=texCmdBody skipwhite skipnl
  syn region texCmdBody contained matchgroup=Delimiter start="{"rs=s+1 skip="\\\\\|\\[{}]"	matchgroup=Delimiter end="}" contains=@texCmdGroup
syn match  texNewEnv				"\\newenvironment\>"			nextgroup=texEnvName skipwhite skipnl
  syn region texEnvName contained matchgroup=Delimiter start="{"rs=s+1  end="}"		nextgroup=texEnvBgn skipwhite skipnl
  syn region texEnvBgn  contained matchgroup=Delimiter start="{"rs=s+1  end="}"		nextgroup=texEnvEnd skipwhite skipnl contains=@texEnvGroup
  syn region texEnvEnd  contained matchgroup=Delimiter start="{"rs=s+1  end="}"		skipwhite skipnl contains=@texEnvGroup

" Definitions/Commands: {{{1
syn match texDefCmd				"\\def\>"				nextgroup=texDefName skipwhite skipnl
if b:tex_stylish
  syn match texDefName contained		"\\[a-zA-Z@]\+"				nextgroup=texDefParms,texCmdBody skipwhite skipnl
  syn match texDefName contained		"\\[^a-zA-Z@]"				nextgroup=texDefParms,texCmdBody skipwhite skipnl
else
  syn match texDefName contained		"\\\a\+"				nextgroup=texDefParms,texCmdBody skipwhite skipnl
  syn match texDefName contained		"\\\A"					nextgroup=texDefParms,texCmdBody skipwhite skipnl
endif
syn match texDefParms  contained		"#[^{]*"	contains=texDefParm	nextgroup=texCmdBody skipwhite skipnl
syn match  texDefParm  contained		"#\d\+"

" TeX Lengths: {{{1
syn match  texLength		"\<\d\+\([.,]\d\+\)\=\s*\(true\)\=\s*\(bp\|cc\|cm\|dd\|em\|ex\|in\|mm\|pc\|pt\|sp\)\>"

" TeX String Delimiters: {{{1
syn match texString		"\(``\|''\|,,\)"

" makeatletter -- makeatother sections
if !s:tex_no_error
  syn region texStyle		matchgroup=texStatement 
	\ start='\\makeatletter'
	\ end='\\makeatother'
	\ contains=@texStyleGroup contained
 syn match  texStyleStatement	"\\[a-zA-Z@]\+"	contained
  syn region texStyleMatcher	matchgroup=Delimiter
	\ start="{"
	\ skip="\\\\\|\\[{}]"
	\ end="}"	
	\ contains=@texStyleGroup,texError	contained
  syn region texStyleMatcher		matchgroup=Delimiter
	\ start="\["			
	\ end="]"	
	\ contains=@texStyleGroup,texError	contained
 endif


 " Math Symbols {{{1
 " (many of these symbols were contributed by Björn Winckler)
  let s:texMathList=[
    \ '|'		,
    \ 'aleph'		,
    \ 'amalg'		,
    \ 'angle'		,
    \ 'approx'		,
    \ 'ast'		,
    \ 'asymp'		,
    \ 'backepsilon'	,
    \ 'backsimeq'	,
    \ 'backslash'	,
    \ 'barwedge'	,
    \ 'because'	,
    \ 'between'	,
    \ 'bigcap'		,
    \ 'bigcirc'	,
    \ 'bigcup'		,
    \ 'bigodot'	,
    \ 'bigoplus'	,
    \ 'bigotimes'	,
    \ 'bigsqcup'	,
    \ 'bigtriangledown',
    \ 'bigtriangleup'	,
    \ 'bigvee'		,
    \ 'bigwedge'	,
    \ 'blacksquare'	,
    \ 'bot'		,
    \ 'bowtie'	        ,
    \ 'boxdot'		,
    \ 'boxminus'	,
    \ 'boxplus'	,
    \ 'boxtimes'	,
    \ 'bullet'	        ,
    \ 'bumpeq'		,
    \ 'Bumpeq'		,
    \ 'cap'		,
    \ 'Cap'		,
    \ 'cdot'		,
    \ 'cdots'		,
    \ 'circ'		,
    \ 'circeq'		,
    \ 'circlearrowleft',
    \ 'circlearrowright', 
    \ 'circledast'	, 
    \ 'circledcirc'	, 
    \ 'clubsuit'	, 
    \ 'complement'	, 
    \ 'cong'		, 
    \ 'coprod'		, 
    \ 'copyright'	, 
    \ 'cup'		, 
    \ 'Cup'		, 
    \ 'curlyeqprec'	, 
    \ 'curlyeqsucc'	, 
    \ 'curlyvee'	, 
    \ 'curlywedge'	, 
    \ 'dagger'	        , 
    \ 'dashv'		, 
    \ 'ddagger'	, 
    \ 'ddots'	        , 
    \ 'diamond'	, 
    \ 'diamondsuit'	, 
    \ 'div'		, 
    \ 'doteq'		, 
    \ 'doteqdot'	, 
    \ 'dotplus'	, 
    \ 'dots'		, 
    \ 'dotsb'		, 
    \ 'dotsc'		, 
    \ 'dotsi'		, 
    \ 'dotso'		, 
    \ 'doublebarwedge'	, 
    \ 'downarrow'	, 
    \ 'Downarrow'	, 
    \ 'ell'		, 
    \ 'emptyset'	, 
    \ 'eqcirc'		, 
    \ 'eqsim'		, 
    \ 'eqslantgtr'	, 
    \ 'eqslantless'	, 
    \ 'equiv'		, 
    \ 'exists'		, 
    \ 'fallingdotseq'	, 
    \ 'flat'		, 
    \ 'forall'		, 
    \ 'frown'		, 
    \ 'ge'		, 
    \ 'geq'		, 
    \ 'geqq'		, 
    \ 'gets'		, 
    \ 'gg'		, 
    \ 'gneqq'		, 
    \ 'gtrdot'		, 
    \ 'gtreqless'	, 
    \ 'gtrless'	, 
    \ 'gtrsim'		, 
    \ 'hat'		, 
    \ 'hbar'		, 
    \ 'heartsuit'	, 
    \ 'hookleftarrow'	, 
    \ 'hookrightarrow'	, 
    \ 'iiint'		, 
    \ 'iint'		, 
    \ 'Im'		, 
    \ 'imath'		, 
    \ 'in'		, 
    \ 'infty'		, 
    \ 'int'		, 
    \ 'lceil'		, 
    \ 'ldots'		, 
    \ 'le'		, 
    \ 'leadsto'	, 
    \ 'left('		, 
    \ 'left\['		, 
    \ 'left\\{'	, 
    \ 'leftarrow'	, 
    \ 'Leftarrow'	, 
    \ 'leftarrowtail'	, 
    \ 'leftharpoondown', 
    \ 'leftharpoonup'	, 
    \ 'leftrightarrow'	, 
    \ 'Leftrightarrow'	, 
    \ 'leftrightsquigarrow', 
    \ 'leftthreetimes'	, 
    \ 'leq'		, 
    \ 'leq'		, 
    \ 'leqq'		, 
    \ 'lessdot'	, 
    \ 'lesseqgtr'	, 
    \ 'lesssim'	, 
    \ 'lfloor'		, 
    \ 'll'		, 
    \ 'lmoustache'     , 
    \ 'lneqq'		, 
    \ 'ltimes'		, 
    \ 'mapsto'		, 
    \ 'measuredangle'	, 
    \ 'mid'		, 
    \ 'models'		, 
    \ 'mp'		, 
    \ 'nabla'		, 
    \ 'natural'	, 
    \ 'ncong'		, 
    \ 'ne'		, 
    \ 'nearrow'	, 
    \ 'neg'		, 
    \ 'neq'		, 
    \ 'nexists'	, 
    \ 'ngeq'		, 
    \ 'ngeqq'		, 
    \ 'ngtr'		, 
    \ 'ni'		, 
    \ 'nleftarrow'	, 
    \ 'nLeftarrow'	, 
    \ 'nLeftrightarrow', 
    \ 'nleq'		, 
    \ 'nleqq'		, 
    \ 'nless'		, 
    \ 'nmid'		, 
    \ 'notin'		, 
    \ 'nprec'		, 
    \ 'nrightarrow'	, 
    \ 'nRightarrow'	, 
    \ 'nsim'		, 
    \ 'nsucc'		, 
    \ 'ntriangleleft'	, 
    \ 'ntrianglelefteq', 
    \ 'ntriangleright'	, 
    \ 'ntrianglerighteq',
    \ 'nvdash'		, 
    \ 'nvDash'		, 
    \ 'nVdash'		, 
    \ 'nwarrow'	, 
    \ 'odot'		, 
    \ 'oint'		, 
    \ 'ominus'		, 
    \ 'oplus'		, 
    \ 'oslash'		, 
    \ 'otimes'		, 
    \ 'owns'		, 
    \ 'P'	        , 
    \ 'parallel'	, 
    \ 'partial'	, 
    \ 'perp'		, 
    \ 'pitchfork'	, 
    \ 'pm'		, 
    \ 'prec'		, 
    \ 'precapprox'	, 
    \ 'preccurlyeq'	, 
    \ 'preceq'		, 
    \ 'precnapprox'	, 
    \ 'precneqq'	, 
    \ 'precsim'	, 
    \ 'prime'		, 
    \ 'prod'		, 
    \ 'propto'		, 
    \ 'rceil'		, 
    \ 'Re'		, 
    \ 'rfloor'		, 
    \ 'right)'		, 
    \ 'right]'		, 
    \ 'right\\}'	, 
    \ 'rightarrow'	, 
    \ 'Rightarrow'	, 
    \ 'rightarrowtail'	, 
    \ 'rightleftharpoons',
    \ 'rightsquigarrow', 
    \ 'rightthreetimes', 
    \ 'risingdotseq'	, 
    \ 'rmoustache'     , 
    \ 'rtimes'		, 
    \ 'S'	        , 
    \ 'searrow'	, 
    \ 'setminus'	, 
    \ 'sharp'		, 
    \ 'sim'		, 
    \ 'simeq'		, 
    \ 'smile'		, 
    \ 'spadesuit'	, 
    \ 'sphericalangle'	, 
    \ 'sqcap'		, 
    \ 'sqcup'		, 
    \ 'sqsubset'	, 
    \ 'sqsubseteq'	, 
    \ 'sqsupset'	, 
    \ 'sqsupseteq'	, 
    \ 'star'		, 
    \ 'subset'		, 
    \ 'Subset'		, 
    \ 'subseteq'	, 
    \ 'subseteqq'	, 
    \ 'subsetneq'	, 
    \ 'subsetneqq'	, 
    \ 'succ'		, 
    \ 'succapprox'	, 
    \ 'succcurlyeq'	, 
    \ 'succeq'		, 
    \ 'succnapprox'	, 
    \ 'succneqq'	, 
    \ 'succsim'	, 
    \ 'sum'		, 
    \ 'supset'		, 
    \ 'Supset'		, 
    \ 'supseteq'	, 
    \ 'supseteqq'	, 
    \ 'supsetneq'	, 
    \ 'supsetneqq'	, 
    \ 'surd'		, 
    \ 'swarrow'	, 
    \ 'therefore'	, 
    \ 'times'		, 
    \ 'to'		, 
    \ 'top'		, 
    \ 'triangle'	, 
    \ 'triangleleft'	, 
    \ 'trianglelefteq'	, 
    \ 'triangleq'	, 
    \ 'triangleright'	, 
    \ 'trianglerighteq', 
    \ 'twoheadleftarrow',
    \ 'twoheadrightarrow',
    \ 'uparrow'	, 
    \ 'Uparrow'	, 
    \ 'updownarrow'	, 
    \ 'Updownarrow'	, 
    \ 'varnothing'	, 
    \ 'vartriangle'	, 
    \ 'vdash'		, 
    \ 'vDash'		, 
    \ 'Vdash'		, 
    \ 'vdots'		, 
    \ 'vee'		, 
    \ 'veebar'		, 
    \ 'Vvdash'		, 
    \ 'wedge'		, 
    \ 'wp'		, 
    \ 'wr'		,
    \ 'HM'		]
  for texmath in s:texMathList
   if texmath =~# '\w$'
    exe "syn match texMathSymbol '\\\\".texmath."\\>' contained"
   else
    exe "syn match texMathSymbol '\\\\".texmath."' contained"
   endif
  endfor

 " Greek {{{1
  fun! s:Greek(group,pat)
    exe 'syn match '.a:group." '".a:pat."' contained"
  endfun
  call s:Greek('texGreek','\\alpha\>'		)
  call s:Greek('texGreek','\\beta\>'		)
  call s:Greek('texGreek','\\gamma\>'		)
  call s:Greek('texGreek','\\delta\>'		)
  call s:Greek('texGreek','\\epsilon\>'		)
  call s:Greek('texGreek','\\varepsilon\>'	)
  call s:Greek('texGreek','\\zeta\>'		)
  call s:Greek('texGreek','\\eta\>'		)
  call s:Greek('texGreek','\\theta\>'		)
  call s:Greek('texGreek','\\vartheta\>'	)
  call s:Greek('texGreek','\\kappa\>'		)
  call s:Greek('texGreek','\\lambda\>'		)
  call s:Greek('texGreek','\\mu\>'		)
  call s:Greek('texGreek','\\nu\>'		)
  call s:Greek('texGreek','\\xi\>'		)
  call s:Greek('texGreek','\\pi\>'		)
  call s:Greek('texGreek','\\varpi\>'		)
  call s:Greek('texGreek','\\rho\>'		)
  call s:Greek('texGreek','\\varrho\>'		)
  call s:Greek('texGreek','\\sigma\>'		)
  call s:Greek('texGreek','\\varsigma\>'	)
  call s:Greek('texGreek','\\tau\>'		)
  call s:Greek('texGreek','\\upsilon\>'		)
  call s:Greek('texGreek','\\phi\>'		)
  call s:Greek('texGreek','\\varphi\>'		)
  call s:Greek('texGreek','\\chi\>'		)
  call s:Greek('texGreek','\\psi\>'		)
  call s:Greek('texGreek','\\omega\>'		)
  call s:Greek('texGreek','\\Gamma\>'		)
  call s:Greek('texGreek','\\Delta\>'		)
  call s:Greek('texGreek','\\Theta\>'		)
  call s:Greek('texGreek','\\Lambda\>'		)
  call s:Greek('texGreek','\\Xi\>'		)
  call s:Greek('texGreek','\\Pi\>'		)
  call s:Greek('texGreek','\\Sigma\>'		)
  call s:Greek('texGreek','\\Upsilon\>'		)
  call s:Greek('texGreek','\\Phi\>'		)
  call s:Greek('texGreek','\\Psi\>'		)
  call s:Greek('texGreek','\\Omega\>'		)
  delfun s:Greek

" ---------------------------------------------------------------------
" LaTeX synchronization: {{{1
syn sync maxlines=200
syn sync minlines=50

syn  sync match texSyncStop			groupthere NONE		"%stopzone\>"

" Synchronization: {{{1
" The $..$ and $$..$$ make for impossible sync patterns
" (one can't tell if a "$$" starts or stops a math zone by itself)
" The following grouptheres coupled with minlines above
" help improve the odds of good syncing.
if !exists("g:tex_no_math")
 syn sync match texSyncMathZoneA	groupthere NONE		"\\end{abstract}"
 syn sync match texSyncMathZoneA	groupthere NONE		"\\end{center}"
 syn sync match texSyncMathZoneA	groupthere NONE		"\\end{description}"
 syn sync match texSyncMathZoneA	groupthere NONE		"\\end{enumerate}"
 syn sync match texSyncMathZoneA	groupthere NONE		"\\end{itemize}"
 syn sync match texSyncMathZoneA	groupthere NONE		"\\end{table}"
 syn sync match texSyncMathZoneA	groupthere NONE		"\\end{tabular}"
 syn sync match texSyncMathZoneA	groupthere NONE		"\\\(sub\)*section\>"
endif


" Highlighting: {{{1
if did_tex_syntax_inits == 1
 let did_tex_syntax_inits= 2
  " TeX highlighting groups which should share similar highlighting
  if !exists("g:tex_no_error")
   if !exists("g:tex_no_math")
    HiLink texBadMath		texError
    HiLink texMathDelimBad	texError
    HiLink texMathError		texError
    if !b:tex_stylish
      HiLink texOnlyMath	texError
    endif
   endif
   HiLink texError		Error
  endif

  hi texBoldStyle		gui=bold	cterm=bold
  hi texItalStyle		gui=italic	cterm=italic
  hi texBoldItalStyle		gui=bold,italic cterm=bold,italic
  hi texItalBoldStyle		gui=bold,italic cterm=bold,italic
  HiLink texCite		texRefZone
  HiLink texDefCmd		texDef
  HiLink texDefName		texDef
  HiLink texDocType		texCmdName
  HiLink texDocTypeArgs		texCmdArgs
  HiLink texInputFileOpt	texCmdArgs
  HiLink texInputCurlies	texDelimiter

  HiLink texLigature		texSpecialChar
  if !exists("g:tex_no_math")
   HiLink texMathDelimSet1	texMathDelim
   HiLink texMathDelimSet2	texMathDelim
   HiLink texMathDelimKey	texMathDelim
   HiLink texMathMatcher	texMath
   HiLink texAccent		texStatement
   HiLink texGreek		texStatement
   HiLink texMathScripts	    Constant
   HiLink texMathSymbol		texStatement
   HiLink texMathZoneV		texMath
   HiLink texMathZoneW		texMath
   HiLink texMathZoneX		texMath
   HiLink texMathZoneY		texMath
   HiLink texMathZoneV		texMath
   HiLink texMathZoneZ		texMath
  endif
  HiLink texBeginEnd		texCmdName
  HiLink texBeginEndName	texSection
  HiLink texSpaceCode		texStatement
  HiLink texStyleStatement	texStatement
  HiLink texTypeSize		texType
  HiLink texTypeStyle		texType
  HiLink texNewCmd		texDef
  HiLink texNewEnv		texDef

   " Basic TeX highlighting groups
  HiLink texCmdArgs		Number
  HiLink texCmdName		Statement
  HiLink texComment		Comment
  HiLink texDef			Statement
  HiLink texDefParm		Special
  HiLink texDelimiter		Delimiter
  HiLink texInput		Special
  HiLink texInputFile		Special
  HiLink texLength		Number
  HiLink texMath		Special
  HiLink texMathDelim		Statement
  HiLink texMathOper		Operator
  HiLink texOption		Number
  HiLink texRefZone		Special
  HiLink texSection		PreCondit
  HiLink texSpaceCodeChar	Special
  HiLink texSpecialChar		SpecialChar
  HiLink texStatement		Statement
  HiLink texString		String
  HiLink texTodo		Todo
  HiLink texType		Type
  HiLink texZone		PreCondit

  delcommand HiLink
endif



" Cleanup: {{{1
unlet s:extfname
let   b:current_syntax = "tex"
let &cpo               = s:keepcpo
unlet s:keepcpo
" vim: ts=8 fdm=marker
