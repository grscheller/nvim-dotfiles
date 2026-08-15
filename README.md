# grscheller/nvim-dotfiles

Repository to maintain and install all my Neovim configuration files
natively on both Linux and Windows 11. This is my actual working setup,
take what may be useful to you, or use as a starting point for your own
version.

## Installation scripts

A MSYS2 POSIX shell script, [nvimInstall](bin/bashInstall), installs the
"dotfiles" from the cloned repo into the appropriate native locations on
Linux and Windows 11. Once installed, does not use WSL or any POSIX
emulation layer. The goal is to have only one platform agnostic Neovim
configuration.

- nvimInstall has shebang `#!/bin/dash`
  - on PopOS `/usr/bin/sh -> dash`
  - on MSYS2 I install dash with `pacman -S dash`
  - will work just fine if shebang is changed to `#!/bin/sh`
- does more than just install, see `nvimInstall --help` 

### Note

Windows 11 integration is still a work in progress. Not sure to what
degree I can leverage the
[XDG directory specification](https://specifications.freedesktop.org/basedir/latest/).

## Public Domain Declaration

To the extent possible under law,
[Geoffrey R. Scheller](https://github.com/grscheller)
has waived all copyright and related or neighboring rights
to [grscheller/dotfiles](https://github.com/grscheller/dotfiles).
This work is published from the United States of America.

See [LICENSE](LICENSE) for details.
