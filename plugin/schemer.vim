if exists('g:schemer_loaded') || &cp
    finish
endif

"""""""""""""""""""""
" Section: Commands "

command! -nargs=1 -complete=color Schemer g:schemer#set_scheme(<q-args>)

