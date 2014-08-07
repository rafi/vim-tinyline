
" vim-tinyline - Tiny status line for Vim
" Maintainer: Rafael Bodill <justrafi@gmail.com>
" Version:    0.1
"--------------------------------------------------------------------

" Configuration {{{1
" Maximum number of directories in filepath
if !exists('g:tinyline_max_dirs')
	let g:tinyline_max_dirs = 3
endif
" Maximum number of characters in each directory
if !exists('g:tinyline_max_dir_chars')
	let g:tinyline_max_dir_chars = 3
endif

" Color palette {{{1
let s:base03  = [ '#151513', 233 ]
let s:base02  = [ '#30302c', 236 ]
let s:base01  = [ '#4e4e43', 239 ]
let s:base00  = [ '#666656', 242 ]
let s:base0   = [ '#808070', 244 ]
let s:base1   = [ '#949484', 246 ]
let s:base2   = [ '#a8a897', 248 ]
let s:base3   = [ '#e8e8d3', 253 ]
let s:yellow  = [ '#ffb964', 215 ]
let s:orange  = [ '#fad07a', 222 ]
let s:red     = [ '#cf6a4c', 167 ]
let s:magenta = [ '#f0a0c0', 217 ]
let s:blue    = [ '#8197bf', 103 ]
let s:cyan    = [ '#8fbfdc', 110 ]
let s:green   = [ '#99ad6a', 107 ]

" Colors for different Vim modes {{{1
let s:normal  = "guifg=".s:base02[0]." guibg=".s:blue[0].   " ctermfg=".s:base02[1]." ctermbg=".s:blue[1]
let s:insert  = "guifg=".s:base02[0]." guibg=".s:green[0].  " ctermfg=".s:base02[1]." ctermbg=".s:green[1]
let s:visual  = "guifg=".s:base02[0]." guibg=".s:magenta[0]." ctermfg=".s:base02[1]." ctermbg=".s:magenta[1]
let s:replace = "guifg=".s:base02[0]." guibg=".s:red[0].    " ctermfg=".s:base02[1]." ctermbg=".s:red[1]

" Set statusline colors {{{1
exec "hi! StatusLine   ctermfg=".s:base02[1]." ctermbg=".s:base2[1]
exec "hi! StatusLineNC ctermfg=".s:base02[1]." ctermbg=".s:base00[1]

" Custom tinyline colors
" Vim mode color
exec "hi User1 ".s:normal
" Percent color
exec "hi User2 guifg=".s:base2[0]. " guibg=".s:base01[0]." ctermfg=".s:base2[1]. " ctermbg=".s:base01[1]
" Line and column color
exec "hi User3 guifg=".s:base02[0]." guibg=".s:base1[0]. " ctermfg=".s:base02[1]." ctermbg=".s:base1[1]
" Readonly color
exec "hi User4 guifg=".s:orange[0]." guibg=".s:base02[0]." ctermfg=".s:orange[1]." ctermbg=".s:base02[1]
" Filepath color
exec "hi User5 guifg=".s:base3[0]. " guibg=".s:base02[0]." ctermfg=".s:base3[1]. " ctermbg=".s:base02[1]
" Write indicator
exec "hi User6 guifg=".s:red[0].   " guibg=".s:base02[0]." ctermfg=".s:red[1].   " ctermbg=".s:base02[1]

" Functions {{{1
" Provides relative path with limited characters in each directory name, and
" limits number of total directories. Caches the result for current buffer.
function! SuperName()
	if (exists('b:tinyline_filepath') && len(b:tinyline_filepath) > 0)
		return b:tinyline_filepath
	endif
	let fname = expand('%:t')
	if (&ft == 'help' || &ft == 'gundo' || &ft == 'diff')
		let b:tinyline_filepath = ''
	elseif (&ft == 'vimfiler')
		let b:tinyline_filepath = vimfiler#get_status_string()
	elseif (fname == '')
		let b:tinyline_filepath = '[No Name]'
	else
		" Shorten dir names
		let short = substitute(expand("%"), "[^/]\\{".g:tinyline_max_dir_chars."}\\zs[^/]\*\\ze/", "", "g")
		" Decrease dir count
		let parts = split(short, '/')
		if (len(parts) > g:tinyline_max_dirs)
			let parts = parts[-g:tinyline_max_dirs-1 : ]
		endif
		let b:tinyline_filepath = join(parts, '/')
	endif
	return b:tinyline_filepath
endfunction

" Using Fugitive plugin, return the Git branch name
function! BranchName()
	if &ft !~? 'vimfiler\|gundo\|diff\|help' && exists("*fugitive#head")
		return fugitive#head(8)
	endif
	return ''
endfunction

" Returns a readonly indicator
function! Readonly()
	return &ft !~? 'help\|vimfiler\|gundo' && &readonly ? '§' : ''
endfunction

" Returns cursor's position percentage of file total
function! Percent()
	return float2nr(100.0 * line('.') / line('$'))
endfunction

" Returns line and column position of cursor
function! Position()
	if (&ft =~? 'gundo\|diff')
		return ''
	endif
	let line_no = line('.')
	let col_no = col('.')
	return repeat(' ', 4-len(line_no)).line_no.':'.col_no.repeat(' ', 3-len(col_no))
endfunction

" Sets color according to current Vim mode
function! s:set_mode_color(mode)
	if (a:mode == 'i')
		exec 'hi! User1 '.s:insert
	elseif (a:mode == 'r')
		exec 'hi! User1 '.s:replace
	else
		exec 'hi! User1 '.s:visual
	endif
endfunction

" Concat the statusline {{{1
" ------------------------------------------=-------------------=--------------
"               Jiberish                    | What da heck?     | Example
" ------------------------------------------+-------------------+--------------
set statusline=                            "| Clear status line |
set statusline+=%1*\ %{mode()}\ %0*        "| Mode              | n
set statusline+=\ #%4*%{Readonly()}%0*%n   "| Buffer & readonly | #§3
set statusline+=%4*%{&paste?'=':''}%0*     "| Paste indicator   | =
set statusline+=\ %5*%{SuperName()}%0*     "| Relative filepath | cor/app.js
set statusline+=%(\ %6*%M%0*%)             "| Write indicator   | +
set statusline+=\ %<                       "| Truncate here     |
set statusline+=%(\‡\ %{BranchName()}%)    "| Git branch name   | ‡ master
set statusline+=%=                         "| Align to right    |
set statusline+=%{&ff}                     "| File format       | unix
set statusline+=%(\ \•\ %{&fenc}%)         "| File encoding     | • utf-8
set statusline+=%(\ \•\ %{&filetype}%)     "| File type         | • javascript
set statusline+=\ %2*\ %3.p%%              "| Percentage        | 88%
set statusline+=\ %3*%{Position()}%0*      "| Line and column   | 69:77
" ------------------------------------------'-------------------'--------------

" Inactive buffer's statusline {{{1
let s:statusline_nc = "\ #%{Readonly()}%n\ %{SuperName()}"
let s:statusline_active = &g:statusline

" Commands {{{1

" Toggle mode color according to insert status
autocmd InsertEnter * call s:set_mode_color(v:insertmode)
autocmd InsertLeave * exec 'hi! User1 '.s:normal

" Toggle buffer's inactive/active statusline
autocmd WinEnter * let &l:statusline = s:statusline_active
autocmd WinLeave * let &l:statusline = s:statusline_nc

" }}}
