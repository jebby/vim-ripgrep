if exists('g:loaded_rg') || &cp
  finish
endif

let g:loaded_rg = 1

let g:rg_binary = get(g:, 'rg_binary', 'rg')
let g:rg_format = get(g:, 'rg_format', '%f:%l:%c:%m')
let g:rg_opts = get(g:, 'rg_opts', '--vimgrep')
let g:rg_root_types = get(g:, 'rg_root_types', ['.git'])
let g:rg_window_location = get(g:, 'rg_window_location', 'botright')
let g:rg_loclist = get(g:, 'rg_loclist', 0)
let g:rg_highlight = get(g:, 'rg_highlight', 0)
let g:rg_highlight_type = get(g:, 'rg_highlight_type', 'Debug')
let g:rg_derive_root = get(g:, 'rg_derive_root', 0)

fun! g:RgVisual() range
  call s:RgGrepContext(function('s:RgSearch'), '"' . s:RgGetVisualSelection() . '"')
endfun

fun! s:Rg(txt)
  call s:RgGrepContext(function('s:RgSearch'), s:RgSearchTerm(a:txt))
endfun

fun! s:RgGetVisualSelection()
    " Why is this not a built-in Vim script function?!
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, "\n")
endfun

fun! s:RgSearchTerm(txt)
  if empty(a:txt)
    return expand("<cword>")
  else
    return a:txt
  endif
endfun

fun! s:RgSearch(txt)
  let l:rgopts = ' '
  let l:rgopts .= &ignorecase ? '-i ' : ''
  let l:rgopts .= &smartcase ? '-S ' : ''
  let l:rgopts .= a:txt
  let l:grep = (g:rg_loclist ? 'l' : '') . 'grep!'
  let l:open = (g:rg_loclist ? 'l': 'c') . 'open'
  let l:close = (g:rg_loclist ? 'l': 'c') . 'close'
  silent! exe l:grep . l:rgopts
  let l:what = {'size': 0}
  let l:entries = g:rg_loclist ? getloclist('.', l:what) : getqflist(l:what)
  if l:entries.size
    exe g:rg_window_location . ' ' . l:open
    redraw!
    if g:rg_highlight
      call s:RgHighlight(a:txt)
    endif
  else
    exe l:close
    redraw!
    echo "No match found for " . a:txt
  endif
endfun

fun! s:RgGrepContext(search, txt)
  let l:grepprgb = &grepprg
  let l:grepformatb = &grepformat
  let &grepprg = g:rg_binary . ' ' . g:rg_opts
  let &grepformat = g:rg_format
  let l:te = &t_te
  let l:ti = &t_ti
  let l:shellpipe_bak=&shellpipe
  set t_te=
  set t_ti=
  if !has("win32")
    let &shellpipe="&>"
  endif

  if g:rg_derive_root
    call s:RgPathContext(a:search, a:txt)
  else
    call a:search(a:txt)
  endif

  let &shellpipe=l:shellpipe_bak
  let &t_te=l:te
  let &t_ti=l:ti
  let &grepprg = l:grepprgb
  let &grepformat = l:grepformatb
endfun

fun! s:RgPathContext(search, txt)
  let l:cwdb = getcwd()
  exe 'lcd '.s:RgRootDir()
  call a:search(a:txt)
  exe 'lcd '.l:cwdb
endfun

fun! s:RgHighlight(txt)
  function! MatchAdd() closure
    call clearmatches()
    call matchadd(g:rg_highlight_type, a:txt)
  endfunction
  augroup rg_highlight
    autocmd! * <buffer>
    autocmd BufWinEnter <buffer> call MatchAdd()
  augroup END
  doautocmd BufWinEnter
endfun

fun! s:RgRootDir()
  let l:cwd = getcwd()
  let l:dirs = split(getcwd(), '/')

  for l:dir in reverse(copy(l:dirs))
    for l:type in g:rg_root_types
      let l:path = s:RgMakePath(l:dirs, l:dir)
      if s:RgHasFile(l:path.'/'.l:type)
        return l:path
      endif
    endfor
  endfor
  return l:cwd
endfun

fun! s:RgMakePath(dirs, dir)
  return '/'.join(a:dirs[0:index(a:dirs, a:dir)], '/')
endfun

fun! s:RgHasFile(path)
  return filereadable(a:path) || isdirectory(a:path)
endfun

fun! s:RgShowRoot()
  if g:rg_derive_root
    echo s:RgRootDir()
  else
    echo getcwd()
  endif
endfun

command! -nargs=* -complete=file Rg :call s:Rg(<q-args>)
command! -complete=file RgRoot :call s:RgShowRoot()
