let g:runy_root = get(g:, 'runy_root', '')
let g:runy_venv = get(g:, 'runy_venv', '')

function! RunyFindRootDirectory(start_dir)
    let l:dir = a:start_dir
    while l:dir !=# '/'
        if filereadable(l:dir . '/pyproject.toml')
            return l:dir
        endif
        let l:dir = fnamemodify(l:dir, ':h')
    endwhile
    return g:runy_root
endfunction

function! RunyFindVenv(root_dir)
    if executable('poetry') && filereadable(a:root_dir . '/pyproject.toml')
        let l:poetry_info = system('cd ' . shellescape(a:root_dir) . ' && poetry env info -p')
        return substitute(l:poetry_info, '\n\+$', '', '')
    endif
    return g:runy_venv
endfunction

function! RunyCopyProject(root_dir, venv_path)
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

function! RunyModifyFile(target_dir)
    let l:current_file = expand('%:p')
    let l:root_dir = RunyFindRootDirectory(fnamemodify(l:current_file, ':p:h'))
    let l:relative_path = substitute(l:current_file, '^' . escape(l:root_dir, '/'), '', '')
    let l:file_path = a:target_dir . l:relative_path
    echom 'Modifying file: ' . l:file_path
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
            let line = substitute(line, '^# > ', '', '')
        endif
        if !l:in_block || line !~ '^# '
            call add(l:new_lines, line)
        endif
    endfor
    call writefile(l:new_lines, l:file_path)
    return l:file_path
endfunction

function! RunyExecute(target_file, venv_path)
    if !exists('g:runy_buffer_size')
        let g:runy_buffer_size = 10
    endif
    if !exists('g:runy_buffer_direction')
        let g:runy_buffer_direction = 'horizontal'
    endif
    if !exists('g:runy_buffer_position')
        let g:runy_buffer_position = 'below'
    endif
    let l:python_cmd = (a:venv_path ==# '') ? 'python3' : a:venv_path . '/bin/python3'
    let l:command = l:python_cmd . ' ' . shellescape(a:target_file)
    let l:output = system(l:command . ' 2>&1')
    let l:bufnr = bufexists('runy_output') ? bufwinnr('runy_output') : -1
    if l:bufnr != -1
        execute l:bufnr . 'wincmd w'
        execute '%delete _'
    else
        let l:position_cmd = (g:runy_buffer_position ==# 'above') ? 'topleft ' : 'botright '
        if g:runy_buffer_direction ==# 'vertical'
            execute 'silent! ' . l:position_cmd . 'vertical new'
            execute 'vertical resize ' . g:runy_buffer_size
        else
            execute 'silent! ' . l:position_cmd . 'new'
            execute 'resize ' . g:runy_buffer_size . '%'
        endif
        execute 'file runy_output'
    endif

    if !empty(l:output)
        call setline(1, split(l:output, "\n"))
    else
        call setline(1, ["No output captured."])
    endif
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    nnoremap <buffer> i <nop>
    nnoremap <buffer> I <nop>
    nnoremap <buffer> a <nop>
    nnoremap <buffer> A <nop>
    nnoremap <buffer> o <nop>
    nnoremap <buffer> O <nop>
    nnoremap <buffer> c <nop>
    nnoremap <buffer> C <nop>
    nnoremap <buffer> s <nop>
    nnoremap <buffer> S <nop>
    if exists(':AnsiEsc')
        execute 'AnsiEsc'
    endif
    redraw!
endfunction

function! Runy()
    let l:current_file = expand('%:p')
    let l:root_dir = RunyFindRootDirectory(fnamemodify(l:current_file, ':p:h'))
    if l:root_dir == ''
        echom 'Root directory not found. Ensure pyproject.toml exists or g:runy_root is set.'
        return
    endif
    let l:venv_path = RunyFindVenv(l:root_dir)
    let l:target_dir = RunyCopyProject(l:root_dir, l:venv_path)
    if l:target_dir == ''
        echom 'Failed to copy project to tmp directory.'
        return
    endif
    let l:target_file = RunyModifyFile(l:target_dir)
    if l:target_file == ''
        echom 'Failed to modify target file.'
        return
    endif
    call RunyExecute(l:target_file, l:venv_path)
endfunction
