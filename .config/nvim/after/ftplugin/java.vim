" Compiler 
:compiler gradlew

" Tabs
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal expandtab

" Ale
let b:ale_fixers = ['google_java_format']
let b:ale_fix_on_save = 1
let g:ale_java_javalsp_jar = '/home/joba/.local/bin/javac-lsp.jar'

" Javacomplete2
setlocal omnifunc=javacomplete#Complete

nnoremap <buffer> <leader>m :w<Cr>:Make build<CR>

