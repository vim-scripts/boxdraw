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
" 2004-06-18 -- fixed ToAscii so it replaces "─"; trace path (g+arrow)


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
  nm g<Up> :call <SID>G(0)<CR>
  nm g<Right> :call <SID>G(1)<CR>
  nm g<Down> :call <SID>G(2)<CR>
  nm g<Left> :call <SID>G(3)<CR>
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
  nun g<Up>
  nun g<Right>
  nun g<Down>
  nun g<Left>
  vu <S-Up>
  vu <S-Down>
  vu <S-Left>
  vu <S-Right>
  nun ,e
  nm ,b :call <SID>S()<CR>
  let &ve=s:ve
  unlet s:ve
  "echo "Finished Boxdrawing mode"
endf

" Try neihgbour in direction 'd' if c is true. Mask m for the direction
" should also be supplied.
" Function returns neighboring bit
" Unicode entries are encoded in utf8 as
"   7 bit : 0vvvvvvv
"  11 bit : 110vvvvv 10vvvvvv
"  16 bit : 1110vvvv 10vvvvvv 10vvvvvv
fu! s:T(c,d,m)
  if(a:c)
    exe 'norm mt'.a:d.'"tyl`t'
    " check if symbol from unicode boxdrawing range
    " E2=1110(0010)
    " 25=  10(0101)xx
    if(0xE2==char2nr(@t[0])&&0x25==char2nr(@t[1])/4)
      let u=char2nr(@t[1])%4*64+char2nr(@t[2])%64
      " u is lower byte of unicode number
      let c='0x'.strpart(s:i_utf8,2*u,2)
      " c is connection code
      "echo 'd='.a:d.' m='.a:m.' c='.c.' u='.u
      retu c%a:m*4/a:m 
    en
  en
endf

" 3*4^x, where x=0,1,2,3
" fu! s:Mask(x)
"   retu ((6+a:x*(45+a:x*(-54+a:x*27)))/2)
" endf

" Move cursor (follow) in specified direction
" Return new direction if new position is valid, -1 otherwise
" dir: 'kljh'
"       ^>V<
"       0123
" mask: 3 12 48 192      
" let @x=3|echo (6+@x*(45+@x*(-54+@x*27)))/2
"
fu! <SID>F(d)
  exe 'norm '.('kljh'[a:d]).'"tyl'
  if(0xE2==char2nr(@t[0])&&0x25==char2nr(@t[1])/4)
    let u=char2nr(@t[1])%4*64+char2nr(@t[2])%64
    " u is lower byte of unicode number
    let c='0x'.strpart(s:i_utf8,2*u,2)
    " c is connection code
  else
    retu -1
  en
  let i=0
  let r=-1
  while i<4
    if 0!=c%4 && a:d!=(i+2)%4
      if r<0
        let r=i
      else
        retu -1
      endif
    endif
    let c=c/4
    let i=i+1
  endw
  retu r
endf

fu! <SID>G(d)
  let y=line(".")
  let x=virtcol(".")
  let n=a:d
  while n>=0
    let n=s:F(n) 
    if y==line(".") && x==virtcol(".") 
      echo "Returned to same spot"
      break
    endif
  endw
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

scriptencoding utf8
command! -range ToAscii :silent <line1>,<line2>s/┌\|┬\|┐\|╓\|╥\|╖\|╒\|╤\|╕\|╔\|╦\|╗\|├\|┼\|┤\|╟\|╫\|╢\|╞\|╪\|╡\|╠\|╬\|╣\|└\|┴\|┘\|╙\|╨\|╜\|╘\|╧\|╛\|╚\|╩\|╝/+/ge|:silent <line1>,<line2>s/[│║]/\|/ge|:silent <line1>,<line2>s/[═─]/-/ge

command! -range ToHorz :<line1>,<line2>s/─\|═/-/g
command! -range ToHorz2 :<line1>,<line2>s/─/-/g
" 0000000: 636f 6d6d 616e 6421 202d 7261 6e67 6520  command! -range 
" 0000010: 546f 486f 727a 203a 3c6c 696e 6531 3e2c  ToHorz :<line1>,
" 0000020: 3c6c 696e 6532 3e73 2fe2 9480 5c7c e295  <line2>s/...\|..
" 0000030: 9029 2f6f 2f67 0d0a                      .)/o/g..
command! -range ToVert :<line1>,<line2>s/│\|║/\|/g

scriptencoding

vmap ,a :ToAscii<cr>

" sideeffect: stores contents of a block in "y 
" 1<C-V> does not work good in 6.0 when multibyte characters are involved
" gvp does not work good ...
" gv also has some problems
fu! s:MB(d)
  let l:y1=line(".")
  let l:x1=virtcol(".")
  "echo l:x1."-".l:y1
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

