" Box drawing module for Vim 6.0
" (C) Andrew Nikitin, 2002
" 2002-01-07 -- created by nsg
" 2002-01-08 -- first box drawing (single only)
" 2002-01-09 -- (00:42) fixed col(".") bug (note vim bug k"tylj does not retu)
" 2002-01-09 -- optimize
" 2002-01-10 -- double boxes
" 2002-01-10 -- SPLITTED from boxdraw.vim
" 2002-01-14 -- <C-V>x instead <C-V>u

let s:o='--b3ba--c4c0d3--cdd4c8----------b3b3----dac3----d5c6------------ba--ba--d6--c7--c9--cc------------------------------------------c4d9bd--c4c1d0------------------bfb4----c2c5--------------------b7--b6--d2--d7--------------------------------------------------cdbebc----------cdcfca----------b8b5------------d1d8------------bb--b9----------cb--ce'
let s:i='----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------115191626090a222a08242815005455415445519260a288aa82a88aa894698640609182466994114'

"
" Activate mode. Assigned to ,b macro.
"
fu! <SID>S()
  let s:ve=&ve
  se ve=all
  nm <S-Up> :call <SID>M(1,'k')<CR>
  nm <S-Down> :call <SID>M(16,'j')<CR>
  nm <S-Left> :call <SID>M(64,'h')<CR>
  nm <S-Right> :call <SID>M(4,'l')<CR>
  nm ,e :call <SID>E()<CR>
  nm ,s :let g:bdlt=1<CR>
  nm ,d :let g:bdlt=2<CR>
  let g:bdlt=1
  nm ,b x
  nun ,b
endf

" Deactivate mode.
" Unmap macros, restore &ve option
fu! <SID>E()
  nun <S-Up>
  nun <S-Down>
  nun <S-Left>
  nun <S-Right>
  nun ,e
  nun ,s
  nun ,d
  nm ,b :call <SID>S()<CR>
  let &ve=s:ve
  "echo "Finished Boxdrawing mode"
endf

" Try neihgbour in direction 'd' id c is true. Mask m for the direction
" should also be supplied.
" Function returns neighboring bit
fu! s:T(c,d,m)
  if(a:c)
    exe 'norm mt'.a:d.'"tyl`t'
    let u=char2nr(@t)
    let c='0x'.strpart(s:i,2*u,2)
    "echo 'd='.a:d.' m='.a:m.' c='.c.' u='.u
    retu c%a:m*4/a:m 
  en
endf

" Move cursor in specified direction (d= h,j,k or l). Mask s for
" the direction should also be supplied
"
fu! <SID>M(s,d)
  let t=@t
  let x=s:T(1<col("."),'h',16)*64+s:T(line(".")<line("$"),'j',4)*16+s:T(1,'l',256)*4+s:T(1<line("."),'k',64)
  let @t=t
  let c=a:s*g:bdlt+x-x%(a:s*4)/a:s*a:s
  "echo 'need c='.c.' x='.x
  let o=strpart(s:o,2*c,2)
  if o!='--' && o!='' 
    exe "norm r\<C-V>u25".o.a:d
  en
"  "echo "Boxdrawing mode"
endf

" Upon start activate boxdrwaing mode.
" If undesirable, prepend with :nmap ,b
"
:call <SID>S()


