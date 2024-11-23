# About

`runpy` is a vim plugin to run Python snippets defined by structured comments. It allow ones to test functions inside a `.py` file without leaving or affecting the file.

# Usage

1. Inside your `py` files add lines starting with `# >`.
2. In the visual mode, select the lines you want to compile (including the lines added as above).
3. Press `ctrl+D`.
4. The selected area will then be compiled taking into account the code inside the `# >` lines, with the output being displayed in a new buffer.

> **Remark.** If none line is selected, the entire file will be compiled.

> **Remark**. You can also add comments in a multi line approach:
> 1. begin a comment block with `# >>> BEGIN`
> 2. end it with `# >>> END`

# Install

As usual.

# ANSI

If the Python output uses ANSI code, they are rendered inside the Vim buffer. However, [AnsiEsc](https://github.com/vim-scripts/AnsiEsc.vim) must be installed.

# Configuration

By default, `runpy` tries to look at [poetry](https://github.com/python-poetry/poetry) configurations. If you are not using `poetry`, you must set the following global variables in your `.vimrc` file:

```
variable                  meaning                          default
-------------------------------------------------------------------------------------------
g:runpy_root              path to project root dir         parent dir containing pyproject.toml
g:runpy_venv              path to project venv             that defined in "poetry venv info"
```

The geometry of the buffer with the output of the executed code can be set as follows:

```
variable                      meaning              default
-------------------------------------------------------------------
g:runpy_buffer_size           buffer size          10
g:runpy_buffer_direction      buffer direction     horizontal
g:runpy_buffer_position       buffer position      below 
```

# To Do

- [ ] add expectation entries with `# <` or `# <<< EXPECT` allowing an evaluation of functions similar to unity tests.
