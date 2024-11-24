# About

`runy` is a vim plugin to run Python snippets defined by structured comments. It allow ones to test functions inside a `.py` file without leaving or affecting the file.

# Usage

1. Inside your `py` files add lines starting with `# >`.
2. In the visual mode, select the lines you want to compile (including the lines added as above).
3. Execute `:call Runy()`.
4. The selected area will then be compiled taking into account the code inside the `# >` lines, with the output being displayed in a new buffer.

> **Remark.** If none line is selected, the entire file will be compiled.

> **Remark**. You can also add comments in a multi line approach:
> 1. begin a comment block with `# >>> BEGIN`
> 2. end it with `# >>> END`

# Install

As usual:
1. clone the repository in your `.vim/plugin` directory:
```bash
git clone https://github.com/ximenesyuri/runy $HOME/.vim/plugin/runy
```
2. or use the installer you want. For instance, if you use [vim-plug](https://github.com/junegunn/vim-plug), add the following to your `vimrc` file and execute `:PlugInstall`:
```vim
call plug#begin()
" ...
Plug 'ximenesyuri/runy'
" ...
call plug#end()
```

# ANSI

If the Python output contains ANSI code, it will be rendered inside the Vim buffer using corresponding Vim syntax highlight. This is done using [AnsiEsc](https://github.com/vim-scripts/AnsiEsc.vim). So, if you need ANSI code compatibility, be sure to have `AnsiEsc` installed.

# Configuration

By default, `runy` tries to look at [poetry](https://github.com/python-poetry/poetry) configurations. If you are not using `poetry`, you must set the following global variables in your `vimrc` file:

```
variable                  meaning                          default
-------------------------------------------------------------------------------------------
g:runy_root              path to project root dir         parent dir containing pyproject.toml
g:runy_venv              path to project venv             that defined in "poetry venv info"
```

The geometry of the buffer with the output of the executed code can be set as follows:

```
variable                     meaning              default
-------------------------------------------------------------------
g:runy_buffer_size           buffer size          10
g:runy_buffer_direction      buffer direction     horizontal
g:runy_buffer_position       buffer position      below 
```

Instead of calling the `Runy` function you can create a keybind to do that for you, say `ctrl+d`:
```vim
augroup RunyGroup
    autocmd!
    autocmd FileType python nnoremap <buffer> <C-d> :call Runy()<CR>
    autocmd FileType python vnoremap <buffer> <C-d> :call Runy()<CR>
augroup END
```

# To Do

- [ ] add expectation entries with `# <` or `# <<< EXPECT` allowing an evaluation of functions similar to unity tests.
