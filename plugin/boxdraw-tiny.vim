"(C) Andrew Nikitin, 2002

fu! <SID>S()
se enc=utf8
let s:ve=&ve|se ve=all
nm<S-Up> :call <SID>M(1,'k')<CR>
nm<S-Down> :call <SID>M(4,'j')<CR>
nm<S-Left> :call <SID>M(8,'h')<CR>
nm<S-Right> :call <SID>M(2,'l')<CR>
nm,e :call <SID>E()<CR>
nun,b
echo"begin Boxdraw"
endf

call <SID>S()

fu! <SID>E()
nun<S-Up>|nun<S-Down>|nun<S-Left>|nun<S-Right>|nun,e
nm,b :call <SID>S()<CR>
let &ve=s:ve
echo"end Boxdraw"
endf

fu! s:T(c,d,m)
if a:c
exe 'norm mt'.a:d.'"tyl`t'
if 226==char2nr(@t)&&37==char2nr(@t[1])/4
let u=char2nr(@t[1])%4*64+char2nr(@t[2])%64
let i=30
wh(i>0)
if u=='0x'.strpart("14[]020c1c[]18003410242c3c",i-6,2)
retu i/2%a:m*2/a:m
en
let i=i-2
endw
en
en
endf

fu! <SID>M(s,d)
let t=@t
let x=s:T(1<col("."),'h',4)*8+s:T(line(".")<line("$"),'j',2)*4+s:T(1,'l',16)*2+s:T(1<line("."),'k',8)
let @t=t
exe "norm r\<C-V>u25".strpart("ff02001402020c1c0018003410242c3c",2*(a:s+x-(x%(a:s*2))/a:s*a:s),2).a:d
endf

