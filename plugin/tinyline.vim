
" vim-tinyline - Tiny status line for Vim
" Maintainer: Rafael Bodill <justrafi@gmail.com>
" Version:    0.6
"-------------------------------------------------

if exists('g:loaded_tinyline') && g:loaded_tinyline
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

" Configuration {{{1
" Maximum number of directories in filepath
if !exists('g:tinyline_max_dirs')
	let g:tinyline_max_dirs = 3
endif
" Maximum number of characters in each directory
if !exists('g:tinyline_max_dir_chars')
	let g:tinyline_max_dir_chars = 5
endif
" Less verbosity on specific filetypes (regexp)
if !exists('g:tinyline_quiet_filetypes')
	let g:tinyline_quiet_filetypes = 'qf\|help\|unite\|vimfiler\|gundo\|diff\|fugitive\|gitv'
endif
" Set syntastic statusline format
if !exists('g:tinyline_disable_syntastic_integration')
	let g:syntastic_stl_format = '%W{%w warnings %fw}%B{ }%E{%e errors %fe}'
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

" Set statusline colors {{{1
highlight StatusLine   ctermfg=236 ctermbg=248 guifg=#30302c guibg=#a8a897
highlight StatusLineNC ctermfg=236 ctermbg=242 guifg=#30302c guibg=#666656

" Custom tinyline colors
" Filepath color
hi User1 guifg=#e8e8d3 guibg=#30302c ctermfg=253 ctermbg=236
" Percent color
hi User2 guifg=#a8a897 guibg=#4e4e43 ctermfg=248 ctermbg=239
" Line and column color
hi User3 guifg=#30302c guibg=#949484 ctermfg=236." ctermbg=246
" Buffer # symbol
hi User4 guifg=#666656 guibg=#30302c ctermfg=242 ctermbg=236
" Write symbol
hi User6 guifg=#cf6a4c guibg=#30302c ctermfg=167 ctermbg=236
" Paste symbol
hi User7 guifg=#99ad6a guibg=#30302c ctermfg=107 ctermbg=236
" Syntastic and whitespace
hi User8 guifg=#ffb964 guibg=#30302c ctermfg=215 ctermbg=236

" Functions {{{1
"
" Provides relative path with limited characters in each directory name, and
" limits number of total directories. Caches the result for current buffer.
function TlSuperName()
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
	return b:tinyline_filepath
endfunction

" Return git branch name, using Fugitive plugin
function TlBranchName()
	if &ft !~? g:tinyline_quiet_filetypes && exists("*fugitive#head")
		return fugitive#head(8)
	endif
	return ''
endfunction

" Returns a read-only symbol
function TlReadonly()
	return &ft !~? g:tinyline_quiet_filetypes && &readonly ? '' : ''
endfunction

" Returns line and column position of cursor.
" Line no. is left-padded by 4-chars, and column no. by 3-chars on the right
function TlPosition()
	if &ft =~? g:tinyline_quiet_filetypes
		return ''
	elseif winwidth(0) < 70
		return line('.')
	endif
	let line_no = line('.')
	let col_no = virtcol('.')
	return repeat(' ', 4-len(line_no)).line_no
			\ .'/'.col_no.repeat(' ', 3-len(col_no))
endfunction

" Returns file format
function TlFormat()
	return &ft =~? g:tinyline_quiet_filetypes ? '' : &ff
endfunction

" Returns syntastic statusline and cache result per buffer
function TlSyntastic()
	" Use buffer's value if cached
	if !exists('b:tinyline_syntastic')
		if &ft =~? g:tinyline_quiet_filetypes
			let b:tinyline_syntastic = ''
		else
			let b:tinyline_syntastic = SyntasticStatuslineFlag()
		endif
	endif
	return b:tinyline_syntastic
endfunction

" Detect trailing whitespace and cache result per buffer
function! TlWhiteSpace()
	if !exists('b:tinyline_whitespace')
		let b:tinyline_whitespace = ''
		if !&readonly && &modifiable && line('$') < 20000
			let trailing = search('\s$', 'nw')
			if trailing != 0
				let b:tinyline_whitespace .= printf('trail%s', trailing)
			endif
		endif
	endif
	return b:tinyline_whitespace
endfunction!

" Concat the active statusline {{{1
" ------------------------------------------=--------------------=------------
"               Gibberish                   | What da heck?      | Example
" ------------------------------------------+--------------------+------------
set statusline=                            "| Clear status line  |
set statusline+=\ %7*%{&paste?'=':''}%*    "| Paste symbol       | =
set statusline+=%4*%{&ro?'':'#'}%*         "| Modifiable symbol  | #
set statusline+=%6*%{TlReadonly()}         "| Readonly symbol    | §
set statusline+=%*%n                       "| Buffer number      | 3
set statusline+=%6*%{&mod?'+':''}%0*       "| Write symbol       | +
set statusline+=\ %1*%{TlSuperName()}%*    "| Relative supername | cor/app.js
set statusline+=\ %<                       "| Truncate here      |
set statusline+=%(\ %{TlBranchName()}\ %) "| Git branch name    | ‡ master
set statusline+=%4*%(%{TlWhiteSpace()}\ %) "| Space and indent   | trail:9
set statusline+=%(%{TlSyntastic()}\ %)%*   "| Syntastic err/info | e2:23
set statusline+=%=                         "| Align to right     |
set statusline+=%{TlFormat()}              "| File format        | unix
set statusline+=%(\ \ %{&fenc}\ \ %)     "| File encoding      | • utf-8 •
set statusline+=%{&ft}                     "| File type          | python
set statusline+=\ \ %2*%{TlPosition()}%*   "| Line and column    | 69/77
" ------------------------------------------'--------------------'------------
" Non-active statusline {{{1
" ------------------------------------------+--------------------+------------
let s:stl_nc = "\ %{&paste?'=':''}"        "| Paste symbol       | =
let s:stl_nc.= "%{TlReadonly()}%n"         "| Readonly & buffer  | §7
let s:stl_nc.= "%6*%{&mod?'+':''}%*"       "| Write symbol       | +
let s:stl_nc.= "\ %{TlSuperName()}"        "| Relative supername | src/main.py
let s:stl_nc.= "%="                        "| Align to right     |
let s:stl_nc.= "%{&ft}\ "                  "| File type          | python
" ------------------------------------------'--------------------'------------

" Auto-commands {{{1

" Store the active statusline for later toggling
let s:stl = &g:statusline

augroup TinyLine
	autocmd!
	" On save, clear whitespace and syntastic statusline we cache
	autocmd BufWritePost * unlet! b:tinyline_whitespace | unlet! b:tinyline_syntastic

	" Toggle buffer's inactive/active statusline
	autocmd WinEnter * let &l:statusline = s:stl
	autocmd WinLeave,SessionLoadPost * let &l:statusline = s:stl_nc
augroup END

" For quickfix windows
"autocmd BufReadPost * let &l:statusline = s:stl

" Loading {{{1
let g:loaded_tinyline = 1

let &cpo = s:save_cpo
unlet s:save_cpo
" }}}
