
# vim-tinyline

A tiny fast statusline for vim. Easy to hack and great for
learning Vim's `statusline`.

## Screenshot
An active statusline:
![tinyline active screenshot](./screen_active.png?raw=true)

An in-active statusline:
![tinyline inactive screenshot](./screen_inactive.png?raw=true)

## Features

- Tiny. [~150LoC](./plugin/tinyline.vim)
- Super filepath: Limits number of directories and characters
- Branch name, using [Fugitive]
- Fast! Caches the filepath per buffer
- Easy to hack and change

## Installation

Use your favorite plugin manager:

* [Pathogen][]
  * `git clone https://github.com/rafi/vim-tinyline.git ~/.vim/bundle/vim-tinyline`
* [Vundle][]
  1. Add `Plugin 'rafi/vim-tinyline'` to .vimrc
  2. Run `:PluginInstall`
* [NeoBundle][]
  1. Add `NeoBundle 'rafi/vim-tinyline'` to .vimrc
  2. Run `:NeoBundleInstall`

## Customization

### Options

Put any of the following options into your `~/.vimrc` in order to overwrite the default behaviour.

| Option                             | Default  | Description                               |
|------------------------------------|----------|-------------------------------------------|
| `let g:tinyline_max_dirs = 2`      | 3        | Limit number of shown directories in path |
| `let g:tinyline_max_dir_chars = 4` | 3        | Limit characters in each directory name   |

## Credits & Contribution

This plugin was developed by Rafael Bodill under the [MIT License][license]. Pull requests are very welcome.

  [Pathogen]: https://github.com/tpope/vim-pathogen
  [Vundle]: https://github.com/gmarik/vundle
  [NeoBundle]: https://github.com/Shougo/neobundle.vim
  [Fugitive]: https://github.com/tpope/vim-fugitive
  [license]: ./LICENSE
