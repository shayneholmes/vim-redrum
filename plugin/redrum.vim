" Copyright 2019 Shayne Holmes
"
" MIT License
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to
" deal in the Software without restriction, including without limitation the
" rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
" sell copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
" FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
" IN THE SOFTWARE.

if &compatible || !has('conceal') || exists('g:redrum_loaded')
  finish
endif
let g:redrum_loaded = 1

" Define defaults
let s:redrum_message = 'All work and no play makes Jack a dull boy. '

function! s:getSetting(name)
  return get(g:, a:name,
        \ get(b:, a:name,
        \ get(s:, a:name)))
endfunction

function! s:createSyntaxRules()
  let str = s:getSetting('redrum_message')
  let len = len(str)
  let i = len - 1
  while i >= 0
    let ch = str[i]
    let next = (i + 1) % len

    " Skip blanks and punctuation so that line beginnings have letters
    let nonblankch = i
    while str[nonblankch] ==# ' '
          \ || str[nonblankch] ==# '.'
      let nonblankch = (nonblankch + 1) % len
    endwhile

    " Make everything contained but the first one, so we always start at the
    " beginning of the string
    if i == 0
      let contained = ''
    else
      let contained = 'contained'
    end
    exec 'syntax match ch'. i
          \ '"."'
          \ 'nextgroup=pre'. next .',ch'. next
          \ 'conceal cchar='. ch
          \ 'skipnl skipwhite'
          \ contained
    exec 'syntax match pre'. i '"^\s*\|\s\{4,}" '
          \ 'nextgroup=pre'. i .',ch'. nonblankch
          \ 'skipnl skipwhite'
          \ contained
    let i -= 1
  endwhile
endfunction

" from code at https://github.com/junegunn/goyo.vim/issues/156
function! s:backup(groups)
  let backup=''
  silent! execute 'redir => backup | ' .
                \ join(map(copy(a:groups), '"hi " . v:val'), ' | ') .
                \ ' | redir END'
  return backup
endfunction

function! s:restore(highlighting_backup)
  let hls = map(split(a:highlighting_backup, '\v\n(\S)@='),
              \ {_, v -> substitute(v, '\v\C(<xxx>|\s|\n)+', ' ', 'g')})
  for hl in hls
    let chunks = split(hl)
    let grp = chunks[0]
    let tail = join(chunks[1:])
    execute 'hi clear ' . grp
    if tail !=# 'cleared'
      let attrs = split(tail, '\v\c(<links\s+to\s+)@=')
      for attr in attrs
        if attr =~? '\v\c^links\s+to\s+'
          execute printf('hi! link %s %s', grp,
                       \ substitute(attr, '\v\c^links\s+to\s+', '', ''))
        else
          execute printf('hi %s %s', grp, attr)
        endif
      endfor
    endif
  endfor
endfunction

function! s:saveSettings()
  let b:redrum_restore={
        \ 'syntax': &l:syntax,
        \ 'conceallevel': &l:conceallevel,
        \ 'concealcursor': &l:concealcursor,
        \ 'highlight': s:backup(['Conceal']),
        \}
endfunction

function! s:restoreSettings()
  let &l:syntax=b:redrum_restore['syntax']
  let &l:conceallevel=b:redrum_restore['conceallevel']
  let &l:concealcursor=b:redrum_restore['concealcursor']
  call s:restore(b:redrum_restore['highlight'])
  unlet b:redrum_restore
endfunction

function! s:activate()
  let b:redrum_active = 1
  call s:saveSettings()
  setlocal syntax=text
  setlocal conceallevel=1
  hi Conceal NONE
  let &l:concealcursor='nciv'
  call s:createSyntaxRules()
endfunction

function! s:deactivate()
  unlet b:redrum_active
  syn clear
  call s:restoreSettings()
endfunction

function! s:Redrum(bang)
  if a:bang
    if get(b:, 'redrum_active', 0)
      call s:deactivate()
    endif
  else
    if get(b:, 'redrum_active', 0)
      call s:deactivate()
    else
      call s:activate()
    endif
  endif
endfunction

command! -bang Redrum call <SID>Redrum(<bang>0)
