" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
plugin/fontsize.vim	[[[1
71
" Plugin for modifying guifont size.
" Maintainer:   Michael Henry (vim at drmikehenry.com)
" License:      This file is placed in the public domain.

if exists("loaded_fontsize")
    finish
endif
let loaded_fontsize = 1

" Save 'cpoptions' and set Vim default to enable line continuations.
let s:save_cpoptions = &cpoptions
set cpoptions&vim

if ! hasmapto("<Plug>FontsizeBegin")
    nmap <silent> <Leader>==  <Plug>FontsizeBegin
endif

if ! hasmapto("<Plug>FontsizeInc", "n")
    nmap <silent> <Leader>++  <Plug>FontsizeInc
endif

if ! hasmapto("<Plug>FontsizeDec", "n")
    nmap <silent> <Leader>--  <Plug>FontsizeDec
endif

if ! hasmapto("<Plug>FontsizeDefault", "n")
    nmap <silent> <Leader>00  <Plug>FontsizeDefault
endif

" Mappings using <SID>m_ are inspired by the bufmru.vim plugin.
" The concept is to enter a "mode" via an initial mapping.  Once
" in this mode, some mode-specific keystrokes now behave as if they
" were mapped.  After 'timeoutlen' milliseconds have elapsed, the
" new "mode" times out and the new "mappings" are effectively disabled.
"
" This emulation of a "mode" is accomplished via a clever techinque
" wherein each operation terminates with a partial mapping to <SID>m_.
" Each new keystroke completes a mapping that itself terminates with
" <SID>m_, keeping an extensible chain of mappings going as long as
" they arrive before 'timeoutlen' milliseconds elapses between keystrokes.

" Externally mappable mappings to internal mappings.
nmap <silent> <Plug>FontsizeBegin       <SID>begin<SID>m_
nmap <silent> <Plug>FontsizeInc         <SID>inc<SID>m_
nmap <silent> <Plug>FontsizeDec         <SID>dec<SID>m_
nmap <silent> <Plug>FontsizeDefault     <SID>default<SID>m_
nmap <silent> <Plug>FontsizeSetDefault  <SID>setDefault<SID>m_
nmap <silent> <Plug>FontsizeQuit        <SID>quit

" "Font size" mode mappings.  m_<KEY> maps <KEY> in "font size" mode.
nmap <silent> <SID>m_+        <SID>inc<SID>m_
nmap <silent> <SID>m_=        <SID>inc<SID>m_
nmap <silent> <SID>m_-        <SID>dec<SID>m_
nmap <silent> <SID>m_0        <SID>default<SID>m_
nmap <silent> <SID>m_!        <SID>setDefault<SID>m_
nmap <silent> <SID>m_q        <SID>quit
nmap <silent> <SID>m_<SPACE>  <SID>quit
nmap <silent> <SID>m_<CR>     <SID>quit
nmap <silent> <SID>m_         <SID>quit

" Action mappings.
nnoremap <silent> <SID>begin       :call fontsize#begin()<CR>
nnoremap <silent> <SID>inc         :call fontsize#inc()<CR>
nnoremap <silent> <SID>dec         :call fontsize#dec()<CR>
nnoremap <silent> <SID>default     :call fontsize#default()<CR>
nnoremap <silent> <SID>setDefault  :call fontsize#setDefault()<CR>
nnoremap <silent> <SID>quit        :call fontsize#quit()<CR>

" Restore saved 'cpoptions'.
let cpoptions = s:save_cpoptions
" vim: sts=4 sw=4 tw=80 et ai:
autoload/fontsize.vim	[[[1
149
" Autoload portion of plugin/fontsize.vim.
" Maintainer:   Michael Henry (vim at drmikehenry.com)
" License:      This file is placed in the public domain.

" Font examples from http://vim.wikia.com/wiki/VimTip632

" Regex values for each platform split guifont into three
" sections (\1, \2, and \3 in capturing parentheses):
"
" - prefix
" - size (possibly fractional)
" - suffix (possibly including extra fonts after commas)

" gui_gtk2: Courier\ New\ 11
let fontsize#regex_gtk2 = '\(.\{-} \)\(\d\+\)\(.*\)'

" gui_photon: Courier\ New:s11
let fontsize#regex_photon = '\(.\{-}:s\)\(\d\+\)\(.*\)'

" gui_kde: Courier\ New/11/-1/5/50/0/0/0/1/0
let fontsize#regex_kde = '\(.\{-}\/\)\(\d\+\)\(.*\)'

" gui_x11: -*-courier-medium-r-normal-*-*-180-*-*-m-*-*
" TODO For now, just taking the first string of digits.
let fontsize#regex_x11 = '\(.\{-}-\)\(\d\+\)\(.*\)'

" gui_other: Courier_New:h11:cDEFAULT
let fontsize#regex_other = '\(.\{-}:h\)\(\d\+\)\(.*\)'

if has("gui_gtk2")
    let s:regex = fontsize#regex_gtk2
elseif has("gui_photon")
    let s:regex = fontsize#regex_photon
elseif has("gui_kde")
    let s:regex = fontsize#regex_kde
elseif has("x11")
    let s:regex = fontsize#regex_x11
else
    let s:regex = fontsize#regex_other
endif

function! fontsize#encodeFont(font)
    if has("iconv") && exists("g:fontsize#encoding")
        let encodedFont = iconv(a:font, &enc, g:fontsize#encoding)
    else
        let encodedFont = a:font
    endif
    return encodedFont
endfunction

function! fontsize#decodeFont(font)
    if has("iconv") && exists("g:fontsize#encoding")
        let decodedFont = iconv(a:font, g:fontsize#encoding, &enc)
    else
        let decodedFont = a:font
    endif
    return decodedFont
endfunction

function! fontsize#getSize(font)
    let decodedFont = fontsize#decodeFont(a:font)
    if match(decodedFont, s:regex) != -1
        " Add zero to convert to integer.
        let size = 0 + substitute(decodedFont, s:regex, '\2', '')
    else
        let size = 0
    endif
    return size
endfunction

function! fontsize#setSize(font, size)
    let decodedFont = fontsize#decodeFont(a:font)
    if match(decodedFont, s:regex) != -1
        let newFont = substitute(decodedFont, s:regex, '\1' . a:size . '\3', '')
    else
        let newFont = decodedFont
    endif
    return fontsize#encodeFont(newFont)
endfunction

function! fontsize#fontString(font)
    let s = fontsize#decodeFont(a:font)
    if len(s) == 0
        let s = "Must :set guifont; :help 'guifont'"
    elseif match(s, s:regex) == -1
        let s = "Bad guifont=" . s
    else
        let s = fontsize#getSize(s) . ": " . s
    endif
    let maxFontLen = 55
    if len(s) > maxFontLen
        let s = s[:maxFontLen - 4] . "..."
    endif
    return s
endfunction

function! fontsize#display()
    redraw
    sleep 100m
    echo fontsize#fontString(&guifont) . " (+/= - 0 ! q CR SP)"
endfunction

function! fontsize#begin()
    call fontsize#display()
endfunction

function! fontsize#quit()
    echo fontsize#fontString(&guifont) . " (Done)"
endfunction

function! fontsize#ensureDefault()
    if ! exists("g:fontsize#defaultSize")
        let g:fontsize#defaultSize = 0
    endif
    if g:fontsize#defaultSize == 0
        let g:fontsize#defaultSize = fontsize#getSize(&guifont)
    endif
endfunction

function! fontsize#default()
    call fontsize#ensureDefault()
    let &guifont = fontsize#setSize(&guifont, g:fontsize#defaultSize)
    let &guifontwide = fontsize#setSize(&guifontwide, g:fontsize#defaultSize)
    call fontsize#display()
endfunction

function! fontsize#setDefault()
    let g:fontsize#defaultSize = fontsize#getSize(&guifont)
endfunction

function! fontsize#inc()
    call fontsize#ensureDefault()
    let newSize = fontsize#getSize(&guifont) + 1
    let &guifont = fontsize#setSize(&guifont, newSize)
    let &guifontwide = fontsize#setSize(&guifontwide, newSize)
    call fontsize#display()
endfunction

function! fontsize#dec()
    call fontsize#ensureDefault()
    let newSize = fontsize#getSize(&guifont) - 1
    if newSize > 0
        let &guifont = fontsize#setSize(&guifont, newSize)
        let &guifontwide = fontsize#setSize(&guifontwide, newSize)
    endif
    call fontsize#display()
endfunction

" vim: sts=4 sw=4 tw=80 et ai:
doc/fontsize.txt	[[[1
176
*fontsize.txt*   Plugin for modifying guifont size

*fontsize*       Version 0.2.0          Last Change:  October 21, 2009

==============================================================================
Introduction                                        |fontsize-intro|
Customization                                       |fontsize-customization|
ChangeLog                                           |fontsize-changelog|
Installation                                        |fontsize-installation|
Credits                                             |fontsize-credits|
TODO                                                |fontsize-todo|
Distribution                                        |fontsize-distribution|

==============================================================================
Introduction                                        *fontsize-intro*

This plugin provides convenient mappings for changing the font size in Gvim.

  <Leader>==    Begin "font size" mode
  <Leader>++    Increment font size
  <Leader>--    Decrement font size
  <Leader>00    Revert to default font size

(Note that by default, <Leader> is the backslash character, so for example
<Leader>++ is invoked by pressing \++ from normal mode.)

The above mappings initiate a "font size" mode in which the following
additional individual keys become active:

  +          Increment font size (may also use = to avoid shift key)
  -          Decrement font size
  0          Revert to default font size
  !          Save current size as new default
  q          Quit "font size" mode
  <SPACE>    Quit "font size" mode
  <CR>       Quit "font size" mode

Other keys pressed will exit "font size" mode and perform their normal
function.

In addition, "font size" mode will automatically timeout after |timeoutlen|
milliseconds have elapsed without a keypress, because "font size" mode is
based on mappings.

Details on customization are found in the |fontsize-customization| section
of the included documentation.

===============================================================================
Customization                                       *fontsize-customization*

The default value of |timeoutlen| is 1000 milliseconds (1 second), which might
be too fast.  The author uses the following setting in his |vimrc|: >

  " Slow down mapping timeout from default 1000 milliseconds.
  set timeoutlen=3000

You may change the mappings that initiate "font size" mode by creating
your own mappings in your |vimrc|file.  For example, use these mappings
to use single characters instead of doubled ones:

  nmap <silent> <Leader>=  <Plug>FontsizeBegin
  nmap <silent> <Leader>+  <Plug>FontsizeInc
  nmap <silent> <Leader>-  <Plug>FontsizeDec
  nmap <silent> <Leader>0  <Plug>FontsizeDefault

Or, use a single mapping to begin "font size" mode and disable other mappings:

  nmap <silent> <F8>                        <Plug>FontsizeBegin
  nmap <silent> <SID>DisableFontsizeInc     <Plug>FontsizeInc
  nmap <silent> <SID>DisableFontsizeDec     <Plug>FontsizeDec
  nmap <silent> <SID>DisableFontsizeDefault <Plug>FontsizeDefault

Any mapping to <Plug>FontsizeXxx overrides the default mappings, even if that
mapping is meaningless like <SID>SomeRandomName.

Normally, the plugin detects the default font size from 'guifont".  This may
be overridden in the |vimrc| file.  E.g., to set the default to 12: >

  let g:fontsize#defaultSize = 12

If your Gvim uses a different encoding for 'guifont' than what's found in
'encoding', you can set g:fontsize#encoding in your |vimrc| file to convert
the font names.  For example, on Chinese Windows XP, the fonts are encoded in
"gbk", so if you use "utf8" for your 'encoding', you'd use the following: >

  let g:fontsize#encoding = "gbk"

(Converting font name encodings requires the +iconv feature.)

===============================================================================
ChangeLog                                           *fontsize-changelog*

Version 0.2.0    Date    2009-10-21                 *fontsize-changelog-0.2.0*

  - Changed <Leader>== to enter "font size" mode without changing the 
    font size.

  - Fixed regex for win32 and others to not require colon after size field
    (e.g., "fontname:h12" works, don't need "fontname:h12:cANSI").  Added
    regex support for other platforms.

  - Added g:fontsize_encoding feature to handle different encodings for
    &guifont and &guifontwide.

  - Handles empty &guifont better now (but cannot change font size in that
    case).

  - Added documentation sections for TODO, ChangeLog.

Version 0.1.0    Date    2009-10-11                 *fontsize-changelog-0.1.0*

  - Initial release.

===============================================================================
Installation                                        *fontsize-installation*

Must be installed using the Vimball plugin, found here:
http://vim.sourceforge.net/scripts/script.php?script_id=1502

Open fontsize-x.y.z.vba with Vim: >

  vim fontsize-x.y.z.vba

With the Vimball open in Vim, extract the files with the :source command: >

  :source %

===============================================================================
Credits                                             *fontsize-credits*

Author: Michael Henry <vim at drmikehenry.com>

Thanks to all the tireless posters on the Vim mailing lists.  I have
benefitted greatly from the detailed and helpful postings contributed daily
by the helpful Vim community.

Thanks also to Andy Wokula, author of the bufmru plugin
(http://www.vim.org/scripts/script.php?script_id=2346),
for writing a clever plugin from which I learned to use
chained keymaps to implement "modes".

===============================================================================
TODO                                                *fontsize-todo*

- Handle empty 'guifont'.  Figure out a way to set 'guifont' to the same font
  Vim uses as a per-platform default, so the size can be read and changed.

- Better support for fractional font sizes.  Currently, they are permitted,
  but only the integer portion is considered.  Therefore it's not possible to
  decrement from 1.5 to 0.5, since the integer portion would become zero
  (which is disallowed).

- Better support for comma-separated fonts in guifont.  Currently, they are
  permitted, but only the first font in the list is updated.  If that font
  isn't present on the system and Vim is not using it, size changes don't
  work.  Consider rotation through comma-separated fonts via < and >.

===============================================================================
Distribution                                        *fontsize-distribution*

- Ensure version and date are correct at top of doc/fontsize.txt.
- Verify date and changes in ChangeLog in doc/fontsize.txt.
- Visually select the following lines:

plugin/fontsize.vim
autoload/fontsize.vim
doc/fontsize.txt

- Create Vimball based on version number (e.g., 0.1.0) as follows: >

  :MkVimball! fontsize-0.1.0

- Distribute fontsize-0.1.0.vba.

===============================================================================
vim:sts=2:et:ai:tw=78:fo=tcq2:ft=help:
