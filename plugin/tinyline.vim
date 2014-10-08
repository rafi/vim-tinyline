
" vim-tinyline - Tiny status line for Vim
" Maintainer: Rafael Bodill <justrafi at gmail dot com>
" Version:    0.7
"-------------------------------------------------

" Disable reload {{{
if exists('g:loaded_tinyline') && g:loaded_tinyline
  finish
endif
let g:loaded_tinyline = 1

" }}}
" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}

" Configuration {{{
" Maximum number of directories in filepath
if ! exists('g:tinyline_max_dirs')
	let g:tinyline_max_dirs = 3
endif
" Maximum number of characters in each directory
if ! exists('g:tinyline_max_dir_chars')
	let g:tinyline_max_dir_chars = 5
endif
" Less verbosity on specific filetypes (regexp)
if ! exists('g:tinyline_quiet_filetypes')
	let g:tinyline_quiet_filetypes = 'qf\|help\|unite\|vimfiler\|gundo\|diff\|fugitive\|gitv'
endif
" Set syntastic statusline format
if ! exists('g:tinyline_disable_syntastic_integration')
	let g:syntastic_stl_format = '%W{%w warnings %fw}%B{ }%E{%e errors %fe}'
endif

" }}}
" Command {{{
command! -nargs=0 -bar -bang TinyLine call s:tinyline('<bang>' == '!')
" }}}

function! s:tinyline(disable) " {{{
	" Toggles TinyLine
	"
	if a:disable
		set statusline=
		augroup TinyLine
			autocmd!
		augroup END
		augroup! TinyLine
	else
		let &l:statusline = s:stl
		call s:colorscheme()
		augroup TinyLine
			autocmd!
			" On save, clear whitespace and syntastic statusline we cache
			autocmd BufWritePost * unlet! b:tinyline_whitespace | unlet! b:tinyline_syntastic

			" Toggle buffer's inactive/active statusline
			autocmd WinEnter,FileType,ColorScheme * let &l:statusline = s:stl
			autocmd WinLeave,SessionLoadPost * let &l:statusline = s:stl_nc

			" For quickfix windows
			"autocmd BufReadPost * let &l:statusline = s:stl
		augroup END
	endif
endfunction

" }}}
function! s:colorscheme() " {{{
	" Set statusline colors
	"
	highlight StatusLine   ctermfg=236 ctermbg=248 guifg=#30302c guibg=#a8a897
	highlight StatusLineNC ctermfg=236 ctermbg=242 guifg=#30302c guibg=#666656

	" Custom tinyline colors
	" Filepath color
	hi User1 guifg=#e8e8d3 guibg=#30302c ctermfg=253 ctermbg=236
	" Percent color
	hi User2 guifg=#a8a897 guibg=#4e4e43 ctermfg=248 ctermbg=239
	" Line and column color
	hi User3 guifg=#30302c guibg=#949484 ctermfg=236 ctermbg=246
	" Buffer # symbol
	hi User4 guifg=#666656 guibg=#30302c ctermfg=242 ctermbg=236
	" Write symbol
	hi User6 guifg=#cf6a4c guibg=#30302c ctermfg=167 ctermbg=236
	" Paste symbol
	hi User7 guifg=#99ad6a guibg=#30302c ctermfg=107 ctermbg=236
	" Syntastic and whitespace
	hi User8 guifg=#ffb964 guibg=#30302c ctermfg=215 ctermbg=236
endfunction

" }}}
function! TlSuperName() " {{{
	" Provides relative path with limited characters in each directory name, and
	" limits number of total directories. Caches the result for current buffer.
	"
	" Use buffer's cached filepath
	if exists('b:tinyline_filepath') && len(b:tinyline_filepath) > 0
		return b:tinyline_filepath
	endif

	" VimFiler status string
	if &ft == 'vimfiler'
		let b:tinyline_filepath = vimfiler#get_status_string()
	" Empty if owned by certain plugins
	elseif &ft =~? g:tinyline_quiet_filetypes
		let b:tinyline_filepath = ''
	" Placeholder for empty buffer
	elseif expand('%:t') == ''
		let b:tinyline_filepath = 'N/A'
	" Regular file
	else
		" Shorten dir names
		let short = substitute(expand("%"), "[^/]\\{".g:tinyline_max_dir_chars."}\\zs[^/]\*\\ze/", "", "g")
		" Decrease dir count
		let parts = split(short, '/')
		if len(parts) > g:tinyline_max_dirs
			let parts = parts[-g:tinyline_max_dirs-1 : ]
		endif
		let b:tinyline_filepath = join(parts, '/')
	endif

	if exists('b:fugitive_type') && b:fugitive_type == 'blob'
		let b:tinyline_filepath .= ' (blob)'
	endif

	return b:tinyline_filepath
endfunction

" }}}
function! TlBranchName() " {{{
	" Return git branch name, using Fugitive plugin
	"
	if &ft !~? g:tinyline_quiet_filetypes && exists("*fugitive#head")
		return fugitive#head(8)
	endif
	return ''
endfunction

" }}}
function! TlReadonly() " {{{
	" Returns a read-only symbol
	"
	return &ft !~? g:tinyline_quiet_filetypes && &readonly ? '' : ''
endfunction

" }}}
function! TlFormat() " {{{
	" Returns file format
	"
	return &ft =~? g:tinyline_quiet_filetypes ? '' : &ff
endfunction

" }}}
function! TlModified() " {{{
	" Make sure we ignore &modified when choosewin is active
	"
	let choosewin = exists('g:choosewin_active') && g:choosewin_active
	return &modified && ! choosewin ? '+' : ''
endfunction

" }}}
function! TlSyntastic()
	" Returns syntastic statusline and cache result per buffer
	"
	" Use buffer's value if cached
	if ! exists('b:tinyline_syntastic')
		if &ft =~? g:tinyline_quiet_filetypes
			let b:tinyline_syntastic = ''
		else
			let b:tinyline_syntastic = SyntasticStatuslineFlag()
		endif
	endif
	return b:tinyline_syntastic
endfunction

" }}}
function! TlWhitespace()
	" Detect trailing whitespace and cache result per buffer
	"
	if ! exists('b:tinyline_whitespace')
		let b:tinyline_whitespace = ''
		if ! &readonly && &modifiable && line('$') < 20000
			let trailing = search('\s$', 'nw')
			if trailing != 0
				let b:tinyline_whitespace .= printf('trail%s', trailing)
			endif
		endif
	endif
	return b:tinyline_whitespace
endfunction!
" }}}

" Concat the active statusline {{{
" ------------------------------------------=--------------------=------------
"               Gibberish                   | What da heck?      | Example
" ------------------------------------------+--------------------+------------
set statusline=                            "| Clear status line  |
set statusline+=\ %7*%{&paste?'=':''}%*    "| Paste symbol       | =
set statusline+=%4*%{&ro?'':'#'}%*         "| Modifiable symbol  | #
set statusline+=%6*%{TlReadonly()}         "| Readonly symbol    | 
set statusline+=%*%n                       "| Buffer number      | 3
set statusline+=%6*%{TlModified()}%0*      "| Write symbol       | +
set statusline+=\ %1*%{TlSuperName()}%*    "| Relative supername | cor/app.js
set statusline+=\ %<                       "| Truncate here      |
set statusline+=%(\ %{TlBranchName()}\ %) "| Git branch name    |  master
set statusline+=%4*%(%{TlWhitespace()}\ %) "| Space and indent   | trail34
set statusline+=%(%{TlSyntastic()}\ %)%*   "| Syntastic err/info | 2 errors 3
set statusline+=%=                         "| Align to right     |
set statusline+=%{TlFormat()}              "| File format        | unix
set statusline+=%(\ \ %{&fenc}\ \ %)     "| File encoding      |  utf-8 
set statusline+=%{&ft}                     "| File type          | python
set statusline+=\ %2*\ %3l:%2c/%3p%%\ %*   "| Line and column    | 69:77/ 90%
" ------------------------------------------'--------------------'---------}}}
" Non-active statusline {{{
" ------------------------------------------+--------------------+------------
let s:stl_nc = "\ %{&paste?'=':''}"        "| Paste symbol       | =
let s:stl_nc.= "%{TlReadonly()}%n"         "| Readonly & buffer  | §7
let s:stl_nc.= "%6*%{TlModified()}%*"      "| Write symbol       | +
let s:stl_nc.= "\ %{TlSuperName()}"        "| Relative supername | src/main.py
let s:stl_nc.= "%="                        "| Align to right     |
let s:stl_nc.= "%{&ft}\ "                  "| File type          | python
" ------------------------------------------'--------------------'---------}}}
" Run-time {{{
" Store the active statusline for later toggling
let s:stl = &g:statusline
" Enable plugin by default
TinyLine
" }}}

" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
unlet s:save_cpo
" }}}

" vim: set ts=2 sw=2 tw=80 noet :
