" 永远的冰点的VIM配置件
" 2011/12/17
" imbingdian@gmail.com
" http://wlog.cn

if v:version < 700
    echoerr 'This _vimrc requires Vim 7 or later.'
    quit
endif

" 设置菜单语言
set langmenu=zh_cn

" =========
" 功能函数
" =========
" 获取当前目录
func GetPWD()
    return substitute(getcwd(), "", "", "g")
endf

" =========
" 环境配置
" =========
" 保留历史记录
set history=600

" 命令行于状态行
set ch=1
set stl=\ [File]\ %F%m%r%h%y[%{&fileformat},%{&fileencoding}]\ %w\ \ [PWD]\ %r%{GetPWD()}%h\ %=\ [Line]\ %l,%c\ %=\ %P 
set ls=2    "始终显示状态行

" 状态栏显示目前所执行的指令
set showcmd

" 控制台响铃(关闭遇到错误时的声音提示)
:set noerrorbells
:set novisualbell
:set t_vb= "close visual bell

" 行控制
set linebreak   "英文单词在换行时不被截断
set nocompatible    "设置不兼容VI
set textwidth=80    "设置每行80个字符自动换行，加上换行符
set wrap    "设置自动折行

" 缩进
set autoindent      "设置自动缩进
set smartindent     "设置智能缩进

" 行号和标尺
set number  "行号
set ruler   "在右下角显示光标位置的状态行
set rulerformat=%15(%c%V\ %p%%%)

" 标签页
set tabpagemax=20   "最多20个标签
set showtabline=2   "总是显示标签栏

" tab转化为4个字符
set tabstop=4
set expandtab
set smarttab
set shiftwidth=4
set softtabstop=4

"设置行高
set linespace=4

" 插入模式下使用 <BS>、<Del> <C-W> <C-U>
set backspace=indent,eol,start

" 自动重新读入
set autoread

" 自动改变当前目录
if has('netbeans_intg')
    set autochdir
endif

"搜索
set ignorecase     "在查找时忽略大小写
set incsearch    "关闭显示查找匹配过程
set hlsearch    "高亮显示搜索的内容

" 显示匹配的括号
" set showmatch

" 匹配配对的字符
func! MatchingQuotes()
    inoremap ( ()<left>
    inoremap [ []<left>
    inoremap { {}<left>
    inoremap " ""<left>
    inoremap ' ''<left>
endf

" 在所有模式下都允许使用鼠标，还可以是n,v,i,c等
set mouse=a

" 恢复上次文件打开位置
set viminfo='10,\"100,:20,%,n~/.viminfo
au BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif

" Diff 模式的时候鼠标同步滚动 for Vim7.3
if has('cursorbind')
    set cursorbind
end

" =====================
" 多语言环境
"    默认为 UTF-8 编码
" =====================
if has("multi_byte")
    set encoding=utf-8
    " English messages only
    "language messages zh_CN.utf-8

    if has('win32')
        language english
        let &termencoding=&encoding
    endif

    set fencs=utf-8,gbk,chinese,latin1
    set formatoptions+=mM
    set nobomb " 不使用 Unicode 签名

    if v:lang =~? '^\(zh\)\|\(ja\)\|\(ko\)'
        set ambiwidth=double
    endif
else
    echoerr "Sorry, this version of (g)vim was not compiled with +multi_byte"
endif

filetype plugin indent on   "打开文件类型检测

" :help mbyte-IME
if has('multi_byte_ime')
    highlight Cursor guibg=#F0E68C guifg=#708090
    highlight CursorIM guibg=Purple guifg=NONE
endif

" =====================
" AutoCmd 自动运行
" =====================
if has("autocmd")

    " 括号自动补全
    func! AutoClose()
        :inoremap ( ()<ESC>i
        :inoremap " ""<ESC>i
        :inoremap ' ''<ESC>i
        :inoremap { {}<ESC>i
        :inoremap [ []<ESC>i
        :inoremap ) <c-r>=ClosePair(')')<CR>
        :inoremap } <c-r>=ClosePair('}')<CR>
        :inoremap ] <c-r>=ClosePair(']')<CR>
    endf

    func! ClosePair(char)
        if getline('.')[col('.') - 1] == a:char
            return "\<Right>"
        else
            return a:char
        endif
    endf

    augroup vimrcEx     "记住上次文件位置
        au!
        autocmd FileType text setlocal textwidth=80
        autocmd BufReadPost *
                    \ if line("'\"") > 0 && line("'\"") <= line("$") |
                    \   exe "normal g`\"" |
                    \ endif
    augroup END

    " Auto close quotation marks for PHP, Javascript, etc, file
    au FileType php,javascript exe AutoClose()
    au FileType php,javascript exe MatchingQuotes()

    " Auto Check Syntax
    " au BufWritePost,FileWritePost *.js,*.php call CheckSyntax(1)

    " JavaScript 语法高亮
    au FileType html,javascript let g:javascript_enable_domhtmlcss = 1
    au BufRead,BufNewFile *.js setf jquery
    
    " 打开javascript对dom、html和css的支持
    let javascript_enable_domhtmlcss=1

    " 给各语言文件添加 Dict
    if has('win32')
        let s:dict_dir = $VIM.'\vimfiles\dict\'
    else
        let s:dict_dir = $HOME."/.vim/dict/"
    endif
    let s:dict_dir = "setlocal dict+=".s:dict_dir

    au FileType php exec s:dict_dir."php_funclist.dict"
    au FileType css exec s:dict_dir."css.dict"
    au FileType javascript exec s:dict_dir."javascript.dict"

    " 增加 ActionScript 语法支持
    au BufNewFile,BufRead,BufEnter,WinEnter,FileType *.as setf actionscript 

    " CSS3 语法支持
    au BufRead,BufNewFile *.css set ft=css syntax=css3

    " 增加 Objective-C 语法支持
    au BufNewFile,BufRead,BufEnter,WinEnter,FileType *.m,*.h setf objc

    " 将指定文件的换行符转换成 UNIX 格式
    au FileType php,javascript,html,css,python,vim,vimwiki set ff=unix

    " 保存编辑状态
    au BufWinLeave * if expand('%') != '' && &buftype == '' | mkview | endif
    au BufRead     * if expand('%') != '' && &buftype == '' | silent loadview | syntax on | endif
endif

" =========
" 图形界面
" =========
if has('gui_running')
    " 只显示菜单
    set guioptions=mcr

    " 高亮光标所在的行
    set cursorline
    
    " 编辑器配色
    "colorscheme zenburn
    "colorscheme dusk
    "colorscheme breeze
    "colorscheme molokai
    
    set background=light "for solarized
    colorscheme solarized


    if has("win32")
        " Windows 兼容配置
        source $VIMRUNTIME/delmenu.vim
	source $VIMRUNTIME/menu.vim 

        " f11 最大化 /vimfiles/extra/fullscreen/gvimfullscreen.dll移动到安装目录
        "nmap <f11> :call libcallnr('gvimfullscreen.dll', 'ToggleFullScreen', 0)<cr>
        "nmap <Leader><Leader> :call libcallnr('gvimfullscreen.dll', 'ToggleFullScreen', 0)<cr>

        " 自动最大化窗口
        au GUIEnter * simalt ~x

        " 给 Win32 下的 gVim 窗口设置透明度 http://www.vim.org/scripts/script.php?script_id=687
        "/vimfiles/extra/vimtweak/vimtweak.dll移动到安装目录
        " au GUIEnter * call libcallnr("vimtweak.dll", "SetAlpha", 250)

        " 字体配置
        "http://support.microsoft.com/kb/306527/zh-cn
        "set guifont=Droid\ Sans\ Mono:h10.5:cANSI
        "set guifontwide=YouYuan:h10.5:cGB2312

        "cygwin路径
        "set shell=d:\cygwin\bin\mintty.exe\ -

    endif

    " Under Mac
    if has("gui_macvim")
        "开启抗锯齿渲染
        set anti
        
        " MacVim 下的字体配置
        "set guifont=Courier_New:h14
        "set guifontwide=YouYuan:h14
        "set guifontwide=Microsoft\ Yahei\ Mono:h14
        "set guifontwide=YouYuan:h13
        "set guifontwide=YouYuan:h14
        "set guifont=Droid\ Sans\ Mono:h14
        "set guifontwide=Yahei_Mono:h14
        set guifont=Monaco:h14
        set guifontwide=YouYuan:h14

        " 半透明和窗口大小
        set transparency=2
        set lines=300 columns=120

        " 使用 MacVim 原生的全屏幕功能
        let s:lines=&lines
        let s:columns=&columns

        func! FullScreenEnter()
            set lines=999 columns=999
            set fu
        endf

        func! FullScreenLeave()
            let &lines=s:lines
            let &columns=s:columns
            set nofu
        endf

        func! FullScreenToggle()
            if &fullscreen
                call FullScreenLeave()
            else
                call FullScreenEnter()
            endif
        endf

        set guioptions+=e
        " Mac 下，按 \\ 切换全屏
        nmap <f11> :call FullScreenToggle()<cr>
        nmap <Leader><Leader> :call FullScreenToggle()<cr>

        " I like TCSH :^)
        set shell=/bin/tcsh

        " Set input method off
        set imdisable

        " Set QuickTemplatePath
        let g:QuickTemplatePath = $HOME.'/.vim/templates/'

        " 如果为空文件，则自动设置当前目录为桌面
        lcd ~/Desktop/
    endif

    " Under Linux/Unix etc.
    if has("unix") && !has('gui_macvim')
        set guifont=Courier\ 10\ Pitch\ 11
    endif
endif

" JSLint.vim
if has("win32")
    let g:jslint_command = $VIMFILES . '/extra/jsl/win/jsl.exe'
else
    let g:jslint_command = $VIMFILES . '/extra/jsl/mac/jsl'
endif
let g:jslint_highlight_color  = '#996600'
"let g:jslint_command_options = '-conf ' .  $VIMFILES . '/extra/jsl/jsl.conf -nofilelisting -nocontext -nosummary -nologo -process'
"let g:jslint_command_options = '-nofilelisting -nocontext -nosummary -nologo -process'

" =========
" 插件
" =========

" Calendar
" http://www.vim.org/scripts/script.php?script_id=52
if has("gui_macvim")
    let g:calendar_diary=$HOME.'/.vim/diary/'
endif
map cal :Calendar<cr>

" NERDTree
" http://www.vim.org/scripts/script.php?script_id=1658
let NERDTreeWinSize=22
map ntree :NERDTree <cr>
map nk :NERDTreeClose <cr>
map <leader>n :NERDTreeToggle<cr>

" 新建 XHTML 、PHP、Javascript 文件的快捷键
nmap <C-c><C-h> :NewQuickTemplateTab xhtml<cr>
nmap  <C-c><C-g> :NewQuickTemplateTab html<cr>
nmap <C-c><C-p> :NewQuickTemplateTab php<cr>
nmap <C-c><C-j> :NewQuickTemplateTab javascript<cr>
nmap <C-c><C-c> :NewQuickTemplateTab css<cr>


" jsbeauty
"http://www.vim.org/scripts/script.php?script_id=2727
" \ff


" =========
" 快捷键
" =========
" 标签相关的快捷键 Ctrl
map tn :tabnext<cr>
map tp :tabprevious<cr>
map tc :tabclose<cr>
map <C-n> :tabnew<cr>
map <C-Tab> :tabnext<cr>

"最近打开的文件
nmap <Leader>mr :MRU<cr>

"字体大小
"http://www.vim.org/scripts/script.php?script_id=2809
"<Leader>==    Begin "font size" mode 
"<Leader>++    Increment font size 
"<Leader>--    Decrement font size 
"<Leader>00    Revert to default font size 

" 在文件名上按gf时，在新的tab中打开
map gf :tabnew <cfile><cr>

" 返回当前时间
func! GetTimeInfo()
    "return strftime('%Y-%m-%d %H:%M:%S')
    return strftime('%Y-%m-%d')
endfunction

" 插入模式按 Ctrl + D(ate) 插入当前时间
imap <C-d> <C-r>=GetTimeInfo()<cr>

"F12启动firefox
if has("win32")
    map <F12> :silent! !"C:\Program Files\Mozilla Firefox\firefox.exe" % <CR>
endif

"zen-coding,(c+y+,)
let g:user_zen_expandabbr_key = '<c-e>'
let g:use_zen_complete_tag = 1

" 保证语法高亮
syntax on

" =========
" 帮助
" =========
" :shell 进入终端
" jsbeauty \ff

set helplang=cn

" =========
" js、css压缩
" =========
"autocmd BufWriteCmd *.js :call CompileJS()  "保存时自动压缩js
"默认 :Gcc 命令压缩js
"autocmd BufWriteCmd *.js :call CompressCss()  "保存时自动压缩css
"默认 :Ycc 命令压缩css