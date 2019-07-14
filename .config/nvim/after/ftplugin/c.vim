" Tabs
setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4
setlocal expandtab

" Ale
let b:ale_fixers = ['clang-format']
let b:ale_c_clangformat_executable = 'clang-format-4.0'
let b:ale_c_clangformat_options = '-style=file'
nnoremap <buffer> <LocalLeader>r :split \| terminal ./build/main

" Compiler
:compiler make
