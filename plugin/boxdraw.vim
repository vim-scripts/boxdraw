" Box drawing module for Vim 6.0
" (C) Andrew Nikitin, 2002
" 2002-01-07 -- created by nsg
" 2002-01-08 -- first box drawing (single only)
" 2002-01-09 -- (00:42) fixed col(".") bug (note vim bug k"tylj does not retu)
" 2002-01-09 -- optimize
" 2002-01-10 -- double boxes


let s:o='--0251--001459--50585a----------0202----0c1c----525e------------51--51--53--5f--54--60------------------------------------------00185c--003468------------------1024----2c3c--------------------56--62--65--6b--------------------------------------------------505b5d----------506769----------5561------------646a------------57--63----------66--6c------------------------------------------------------------------01'
let s:i='44cc11------------------14------50------05------41------15--------------51--------------54--------------45--------------55--------------------------------------88221824289060a009060a81428219262a9162a29864a889468a9966aa14504105------40010410'

"
" Activate mode. Assigned to ,b macro.
"
fu! <SID>S()
  se enc=utf8
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
    if(0xE2==char2nr(@t[0])&&0x25==char2nr(@t[1])/4)
      let u=char2nr(@t[1])%4*64+char2nr(@t[2])%64
      let c='0x'.strpart(s:i,2*u,2)
      "echo 'd='.a:d.' m='.a:m.' c='.c.' u='.u
      retu c%a:m*4/a:m 
    en
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


