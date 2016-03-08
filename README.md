
# vim-tinyline

A tiny fast statusline for vim. Easy to hack and great for
learning Vim's `statusline`.

## Screenshot
An active statusline:
![tinyline active screenshot](https://paste.xinu.at/Such9/)

An in-active statusline:
![tinyline inactive screenshot](https://paste.xinu.at/0SO/)

## Features

- Tiny. [~150LoC](./plugin/tinyline.vim)
- Super filepath: Limits number of directories and characters
- Branch name, using [Fugitive]
- Detects [ChooseWin] active, and [Fugitive]'s blobs
- Fast! Caches the filepath per buffer
- Easy to hack and change

## Installation

Use your favorite plugin manager to add 'rafi/vim-tinyline' to your `.vimrc`.

## Customization

### Options

Put any of the following options into your `~/.vimrc` in order to overwrite the default behaviour.

| Option                             | Default  | Description                               |
|------------------------------------|----------|-------------------------------------------|
| `let g:tinyline_max_dirs = 2`      | 3        | Limit number of shown directories in path |
| `let g:tinyline_max_dir_chars = 4` | 3        | Limit characters in each directory name   |

## Credits & Contribution

This plugin was developed by Rafael Bodill under the [MIT License][license]. Pull requests are very welcome.

  [Fugitive]: https://github.com/tpope/vim-fugitive
  [ChooseWin]: https://github.com/t9md/vim-choosewin
  [license]: ./LICENSE
