let g:runpy_root = get(g:, 'runpy_root', '')
let g:runpy_venv = get(g:, 'runpy_venv', '')

function! RunPyFindRootDirectory(start_dir)
    let l:dir = a:start_dir
    while l:dir !=# '/'
        if filereadable(l:dir . '/pyproject.toml')
            return l:dir
        endif
        let l:dir = fnamemodify(l:dir, ':h')
    endwhile
    return g:runpy_root
endfunction

function! RunPyFindVenv(root_dir)
    if executable('poetry') && filereadable(a:root_dir . '/pyproject.toml')
        let l:poetry_info = system('cd ' . shellescape(a:root_dir) . ' && poetry env info -p')
        return substitute(l:poetry_info, '\n\+$', '', '')
    endif
    return g:runpy_venv
endfunction

function! RunPyCopyProject(root_dir, venv_path)
    if a:venv_path ==# ''
        let l:hash = substitute(system('head /dev/urandom | tr -dc A-Za-z0-9 | head -c 10'), '\n\+$', '', '')
    else
        let l:hash = fnamemodify(a:venv_path, ':t')
    endif
    let l:target_dir = '/tmp/' . fnamemodify(a:root_dir, ':t') . '-' . l:hash

    echom 'Target directory: ' . l:target_dir

    call system('mkdir -p ' . shellescape(l:target_dir))
    call system('cp -r ' . shellescape(a:root_dir) . '/* ' . shellescape(l:target_dir))

    if !isdirectory(l:target_dir)
        echom 'Failed to create target directory: ' . l:target_dir
        return ''
    endif
    return l:target_dir
endfunction

function! RunPyModifyFile(target_dir)
    let l:file_path = a:target_dir . '/' . expand('%:t')

    " Check if file_path exists
    if !filereadable(l:file_path)
        echom 'File does not exist: ' . l:file_path
        return ''
    endif

    let l:lines = readfile(l:file_path)

    let l:new_lines = []
    let l:in_block = 0

    for line in l:lines
        if line =~ '^# >>> BEGIN'
            let l:in_block = 1
        endif

        if l:in_block
            if line =~ '^# ' | continue | endif
            if line =~ '^# >>> END'
                let l:in_block = 0
                continue
            endif
        endif
        
        if line =~ '^# >'
            let line = substitute(line, '^# >', '', '')
        endif

        if !l:in_block || line !~ '^# '
            " Collecting valid lines
            call add(l:new_lines, line)
        endif
    endfor

    call writefile(l:new_lines, l:file_path)

    return l:file_path
endfunction

function! RunPyExecute(target_file, venv_path)
    let l:python_cmd = (a:venv_path ==# '') ? 'python3' : a:venv_path . '/bin/python3'
    let l:output = system(l:python_cmd . ' ' . shellescape(a:target_file))
    execute 'new'
    call setline(1, split(l:output, "\n"))
    setlocal buftype=nofile
    setlocal bufhidden=hide
endfunction

function! RunPy()
    let l:current_file = expand('%:p')
    let l:root_dir = RunPyFindRootDirectory(fnamemodify(l:current_file, ':p:h'))
    let l:venv_path = RunPyFindVenv(l:root_dir)
    let l:target_dir = RunPyCopyProject(l:root_dir, l:venv_path)
    let l:target_file = RunPyModifyFile(l:target_dir)
    call RunPyExecute(l:target_file, l:venv_path)
endfunction
