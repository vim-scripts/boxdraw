" Box drawing module for Vim 6.0
" 2002-01-07 -- created by nsg
" 2002-01-08 -- first box drawing (single only)
" 2002-01-09 -- (00:42) fixed col(".") bug (note vim bug k"tylj does not retu)
" 2002-01-09 -- optimize
fu! <SID>S()
se enc=utf8
let s:ve=&ve
se ve=all
nm <S-Up> :call <SID>M(1,'k')<CR>
nm <S-Down> :call <SID>M(4,'j')<CR>
nm <S-Left> :call <SID>M(8,'h')<CR>
nm <S-Right> :call <SID>M(2,'l')<CR>
echo "Boxdrawing mode: use Shift+arrows to draw boxes"
endf

nm ,b :call <SID>S()<CR>
nm ,e :call <SID>E()<CR>
norm ,b

fu! <SID>E()
if(''==s:ve)
echo "Not in boxdrawing mode"
retu
en
nun <S-Up>
nun <S-Down>
nun <S-Left>
nun <S-Right>
let &ve=s:ve
let s:ve=''
echo "Finished Boxdrawing mode"
endf

fu! s:T(c,d,m)
if(a:c)
exe 'norm mt'.a:d.'"tyl`t'
if(0xE2==char2nr(@t[0])&&0x25==char2nr(@t[1])/4)
let uni=(char2nr(@t[0])%16*64+char2nr(@t[1])%64)*64+char2nr(@t[2])%64
let i=0
wh(i<32)
if(uni=='0x25'.strpart("[][][]14[]020c1c[]18003410242c3c",i,2))
retu i/2%a:m*2/a:m
en
let i=i+2
endw
en
en
endf

fu! <SID>M(s,d)
let t=@t
let x=s:T(1<col("."),'h',4)*8+s:T(line(".")<line("$"),'j',2)*4+s:T(1,'l',16)*2+s:T(1<line("."),'k',8)
let @t=t
let c=(a:s+x-(x%(a:s*2))/a:s*a:s)
exe "norm r\<C-V>u25".strpart("  02001402020c1c0018003410242c3c",2*c,2).a:d
endf

