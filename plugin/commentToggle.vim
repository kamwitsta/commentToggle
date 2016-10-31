" ----------------------------------------------------------------- "
" name			commentToggle										"
" description	A simple line-based comment toggler					"
" author		kamil.stachowski@gmail.com							"
" license		GPLv3+												"
" version		0.3 (2016.11.01)									"
" ----------------------------------------------------------------- "

" = intro ===================================================================================== {{{ =

" make sure the plugin hasn't been loaded yet and save something
if exists("g:loaded_commentToggle") || &cp
	finish
endif
let g:loaded_commentToggle = "v0.2"
let s:cpoSave = &cpo
set cpo&vim

" assign a shortcut
if !hasmapto('<Plug>CommentToggle')
	map <unique> <Leader>; <Plug>CommentToggle
endif
noremap <silent> <unique> <script> <Plug>CommentToggle :call <SID>CommentToggle()<CR>
noremenu <script> Plugin.Add\ CommentToggle <SID>CommentToggle

" and a command just in case
if !exists(":commentToggle")
command -nargs=1 CommentToggle :call s:CommentToggle()
endif

" ============================================================================================= }}} =
" = functions ================================================================================= {{{ =

" - s:CommentCheckCommented ------------------------------------------------------------------- {{{ -

" check if line aLineNr begins with string
function! s:CommentCheckCommented(aLineNr, aCommStr)
	" check if the line begins with the comment opening string, ignoring whitespace
	return match(getline(a:aLineNr), '^\s*' . a:aCommStr[0]) == ""
endfunction

" --------------------------------------------------------------------------------------------- }}} -
" - s:CommentToggle --------------------------------------------------------------------------- {{{ -

" the main part
" finds the comment string for the current syntax, and if the current line is already commented;
" if it is, it uncomments it; if it's not, it uncomments it
function! s:CommentToggle()
	let s:commStr = split(&commentstring, "%s", 1)
	let s:commed = s:CommentCheckCommented(line("."), s:commStr)
	if match(getline(line(".")), '\S') != -1						" no point commenting empty lines
		call s:CommentToggleHelper(line("."), s:commStr, s:commed)
	endif
endfunction

" --------------------------------------------------------------------------------------------- }}} -
" - s:CommentToggleHelper --------------------------------------------------------------------- {{{ -

" toggles comment on line aLineNr with string aCommStr depending on whether the line is already commented (aCommed)
function! s:CommentToggleHelper(aLineNr, aCommStr, aCommed)
	if a:aCommed
		let s:tmpToBeSubsted = '\(\s*\)' . a:aCommStr[0] . '\(\s*\)\(.\{-}\)\(\s*\)' . a:aCommStr[1]
		let s:tmpToSubst = '\1\3'							" remove the comment string(s) and all superfluous whitespace (hence greedy match in \3)
	else
		let s:tmpToBeSubsted='\(\s*\)\(.*\)'" leave the whitespace in the beginning untouched
		let s:tmpToSubst = '\1' . a:aCommStr[0] . ' \2'		"	add extra spaces inside the comment string
		if a:aCommStr[1] != ""								"	but not after it in case the language supports single line comments
			let s:tmpToSubst = s:tmpToSubst . ' ' . a:aCommStr[1]
		endif
	endif
	call setline(a:aLineNr, substitute(getline(a:aLineNr), s:tmpToBeSubsted, s:tmpToSubst, ""))
endfunction

" --------------------------------------------------------------------------------------------- }}} -

" ============================================================================================= }}} =
" = outro ===================================================================================== {{{ =

let &cpo = s:cpoSave
unlet s:cpoSave

" ============================================================================================= }}} =
