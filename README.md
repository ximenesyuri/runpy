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

# To Do

- [ ] add expectation entries with `# <` or `# <<< EXPECT` allowing an evaluation of functions similar to unity tests.
