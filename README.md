# nvim

Personal Neovim configuration

## Symlink

```sh
ln -sfn ~/repos/nvim ~/.config/nvim
```

## Installation and Dependencies

### Common

```sh
mise use -g go node python
```

### Fedora

```sh
sudo dnf install neovim fd-find ripgrep tree-sitter-cli gcc ImageMagick
```

### macOS

```sh
brew install neovim fd ripgrep tree-sitter-cli imagemagick
```

### Terminal

- Use a [Nerd Font](https://www.nerdfonts.com) for file icons
- Image previews need a terminal with image support (Kitty, WezTerm or Ghostty)
