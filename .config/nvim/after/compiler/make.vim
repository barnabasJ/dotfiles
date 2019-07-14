" Vim Compiler File
" Compiler: make
"
if exists("current_compiler")
  finish
endif
let current_compiler = "make;"

if exists(":CompilerSet") != 2 " older Vim used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

CompilerSet makeprg=make

CompilerSet errorformat=
      \%-C%p^,
      \%+C\ \ %#%m,
      \%-C%.%#,
      \%A%f:%l:%c:\ error:\ %m,
      \%+Z\ %#,
      \%-Gclang%.%#,
