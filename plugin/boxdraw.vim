" Box drawing module for Vim 6.0
" (C) Andrew Nikitin, 2002
" 2002-01-07 -- created by nsg
" 2002-01-08 -- first box drawing (single only)
" 2002-01-09 -- (00:42) fixed col(".") bug (note vim bug k"tylj does not retu)
" 2002-01-09 -- optimize
" 2002-01-10 -- double boxes
" 2002-01-16 -- use script-local var and access function instead of global
" 2002-01-30 -- ,a mapping (box->ascii conversion)
" 2003-11-10 -- implemented MB avoiding "number Ctl-V"


let s:o_utf8='--0251--001459--50585a----------0202----0c1c----525e------------51--51--53--5f--54--60------------------------------------------00185c--003468------------------1024----2c3c--------------------56--62--65--6b--------------------------------------------------505b5d----------506769----------5561------------646a------------57--63----------66--6c------------------------------------------------------------------01'
let s:i_utf8='44cc11------------------14------50------05------41------15--------------51--------------54--------------45--------------55--------------------------------------88221824289060a009060a81428219262a9162a29864a889468a9966aa14504105------40010410'

"
" Activate mode. Assigned to ,b macro.
"
fu! <SID>S()
  if has("gui_running")
    se enc=utf8
  en
  let s:ve=&ve
  setl ve=all
  nm <S-Up> :call <SID>M(1,'k')<CR>
  nm <S-Down> :call <SID>M(16,'j')<CR>
  nm <S-Left> :call <SID>M(64,'h')<CR>
  nm <S-Right> :call <SID>M(4,'l')<CR>
  vm <S-Up>     <esc>:call <SID>MB('k')<CR>
  vm <S-Down>   <esc>:call <SID>MB('j')<CR>
  vm <S-Left>   <esc>:call <SID>MB('h')<CR>
  vm <S-Right>  <esc>:call <SID>MB('l')<CR>
  nm ,e :call <SID>E()<CR>
  nm ,s :call <SID>SetLT(1)<CR>
  nm ,d :call <SID>SetLT(2)<CR>
  let s:bdlt=1
  nm ,b x
  nun ,b
endf

fu! s:SetLT(thickness)
  let s:bdlt=a:thickness
endf

" Deactivate mode.
" Unmap macros, restore &ve option
fu! <SID>E()
  nun <S-Up>
  nun <S-Down>
  nun <S-Left>
  nun <S-Right>
  vu <S-Up>
  vu <S-Down>
  vu <S-Left>
  vu <S-Right>
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
      let c='0x'.strpart(s:i_utf8,2*u,2)
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
  let c=a:s*s:bdlt+x-x%(a:s*4)/a:s*a:s
  "echo 'need c='.c.' x='.x
  let o=strpart(s:o_utf8,2*c,2)
  if o!='--' && o!='' 
    exe "norm r\<C-V>u25".o.a:d
  en
"  "echo "Boxdrawing mode"
endf

fu! s:ToAscii()
  exe expand("normal <esc>")
  echo "Hello"
"  exe "normal :s/[<C-V>u2500]/-/g"
  exec "normal gv:s/[<C-V>u2550]/-/g<CR>"
" normal gv:s/[<C-V>u2502<C-V>u2551]/<bar>g<CR>
" normal gv:s/[<C-V>u250c<C-V>u252c<C-V>u2510<C-V>u251c<C-V>u253c<C-V>u2524<C-V>u2514<C-V>u2534<C-V>u2518]/+/g<CR>
" normal gv:s/[<C-V>u2554<C-V>u2566<C-V>u2557<C-V>u2560<C-V>u256c<C-V>u2563<C-V>u255a<C-V>u2569<C-V>u255d]/#/g<CR>
" normal gv:s/[<C-V>u2552<C-V>u2564<C-V>u2555<C-V>u255e<C-V>u256a<C-V>u2561<C-V>u2558<C-V>u2567<C-V>u255b<C-V>u2553<C-V>u2565<C-V>u2556<C-V>u255f<C-V>u256b<C-V>u2562<C-V>u2559<C-V>u2568<C-V>u255c]/+/g<CR>
endf

vmap ,a :call <SID>ToAscii()<CR>

" sideeffect: stores contents of a block in "y 
" 1<C-V> does not work good in 6.0 when multibyte characters are involved
" gvp does not work good ...
" gv also has some problems
fu! s:MB(d)
  let l:y1=line(".")
  let l:x1=virtcol(".")
  " echo l:x1."-".l:y1
  normal gv"yygvo
  let l:y2=line(".")
  let l:x2=virtcol(".")
  if l:x1>l:x2 | let l:t=l:x1 | let l:x1=l:x2 | let l:x2=l:t | endif
  if l:y1>l:y2 | let l:t=l:y1 | let l:y1=l:y2 | let l:y2=l:t | endif
  let l:pos=l:y1."G0"
  if 1<l:x1 | let l:pos=l:pos.(l:x1-1)."l" | endif
  let l:size=""
  if 0<l:y2-l:y1 | let l:size=l:size.(l:y2-l:y1)."j" | endif
  if 0<l:x2-l:x1 | let l:size=l:size.(l:x2-l:x1)."l" | endif
  " echo l:x1."-".l:x2."  ".l:y1."-".l:y2." ".l:pos." ".l:size
  " echo "normal gvr-".l:pos.a:d."".l:size."\"ypgv"
  exe "normal gvr ".l:pos.a:d."".l:size."d\"yPgvjk"
endf

" Upon start activate boxdrwaing mode.
" If undesirable, prepend with :nmap ,b
"
:call <SID>S()



