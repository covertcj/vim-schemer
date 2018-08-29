"""""""""""""""""""""""""""""""""""""
""" Section: MyColorScheme workaround
""" See: https://github.com/altercation/solarized/issues/102
if !exists('s:known_links')
    let s:known_links = {}
endif

function! s:find_links() " {{{1 Find and remember links between highlighting groups.
    redir => listing
    try
        silent highlight
    finally
        redir END
    endtry
    for line in split(listing, "\n")
        let tokens = split(line)
        " We're looking for lines like "String xxx links to Constant" in the
        " output of the :highlight command.
        if len(tokens) == 5 && tokens[1] == 'xxx' && tokens[2] == 'links' && tokens[3] == 'to'
            let fromgroup = tokens[0]
            let togroup = tokens[4]
            let s:known_links[fromgroup] = togroup
        endif
    endfor
endfunction

function! s:restore_links() " {{{1
    " Restore broken links between highlighting groups.
    redir => listing
    try
        silent highlight
    finally
        redir END
    endtry
    let num_restored = 0
    for line in split(listing, "\n")
        let tokens = split(line)
        " We're looking for lines like "String xxx cleared" in the
        " output of the :highlight command.
        if len(tokens) == 3 && tokens[1] == 'xxx' && tokens[2] == 'cleared'
            let fromgroup = tokens[0]
            let togroup = get(s:known_links, fromgroup, '')
            if !empty(togroup)
                execute 'hi link' fromgroup togroup
                let num_restored += 1
            endif
        endif
    endfor
endfunction

function! s:accurate_colorscheme(colo_name)
    call <SID>find_links()
    exec "colorscheme " a:colo_name
    call <SID>restore_links()
endfunction


""""""""""""""""""""
" Section: Variables

let g:schemer_base_dir = fnamemodify($MYVIMRC, ':p:h')
let g:schemer_persistence_file_name = 'schemer_persist.vim'
let g:schemer_persistence_file = g:schemer_base_dir.'/'.g:schemer_persistence_file_name


""""""""""""""""""""
" Section: Functions

function! schemer#set_scheme(scheme)
    if exists('g:schemer_persistence_file')
        call writefile(['let g:schemer_persisted_scheme = "'.a:scheme.'"'], g:schemer_persistence_file)
    endif

    call s:accurate_colorscheme(a:scheme)
endfunction

function! schemer#set_default_scheme(scheme)
    let g:schemer_default_scheme = a:scheme
endfunction

function! schemer#load_scheme()
    if exists('g:schemer_persistence_file')
        if filereadable(g:schemer_persistence_file)
            exec 'source ' . g:schemer_persistence_file
        endif
    endif       

    if exists('g:schemer_persisted_scheme')
        let l:scheme = g:schemer_persisted_scheme
    elseif exists('g:schemer_default_scheme')
        let l:scheme = g:schemer_default_scheme
    else
        echoerr 'No default or persisted theme detected'
        return
    endif

    call schemer#set_scheme(l:scheme)
endfunction

