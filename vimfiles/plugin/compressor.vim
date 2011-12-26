" File:         compressor.vim
" Author:       bingdian(imbingdian@gmail.com)
" Link:         http://wlog.cn/
" Version:      0.1, 2011/12/24
" Description:  Google Closure Compiler & yuicompressor for vim
"               http://code.google.com/closure/compiler/
"               http://yuilibrary.com/download/yuicompressor/

" =====================
" CompileJS
" =====================
function! CompileJS()
    let src = expand('%:p')
    let build_dir = expand('%:p:h')
    let build_filename = expand('%:r.js')
    let file_extension = expand('%:e')	
    if has('win32')
        let compiler_path = $VIM.'\vimfiles\extra\closurecompiler\compiler.jar'
    else
        let compiler_path = $HOME.'/.vim/extra/closurecompiler/compiler.jar'
    endif
    
    if file_extension == 'js'
        execute "! java -jar " . compiler_path . " --js " . src . " --js_output_file " . build_dir . "/" . build_filename . "-min.js"
    endif
endfunction

" =====================
" CompressCss
" =====================
function! CompressCss()
    let src = expand('%:p')
    let build_dir = expand('%:p:h')
    let build_filename = expand('%:r.css')
    let file_extension = expand('%:e')	
    if has('win32')
        let yui_path = $VIM.'\vimfiles\extra\yuicompressor\yuicompressor.jar'
    else
        let yui_path = $HOME.'/.vim/extra/yuicompressor/yuicompressor.jar'
    endif
    
    if file_extension == 'css'
        execute "! java -jar " . yui_path . " --charset UTF-8 " . src . " -o " . build_filename . "-min.css"
    endif
endfunction


" =====================
" command
" =====================
command! -nargs=* Gcc :call CompileJS()
command! -nargs=* Ycc :call CompressCss()
