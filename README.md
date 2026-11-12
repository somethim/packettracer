# Cisco Packet Tracer installer

Installs Cisco Packet Tracer with a `packettracer` command, an app-launcher entry and an icon.
The Cisco `.deb` is not stored in git (it is ~400 MB); it is attached to this repo's
[GitHub release](https://github.com/somethim/packettracer/releases) and downloaded on demand.
The repo is private because Cisco's EULA does not allow redistributing the installer.

## Requirements

- [`gh`](https://cli.github.com/), logged in (`gh auth login`), to download the `.deb`
- `make`, `ar` (binutils), `tar`, `xz`
- FUSE 2 to run the AppImage:
  - Arch: `fuse2` (pulled in automatically)
  - Fedora: `sudo dnf install fuse-libs`
  - Debian/Ubuntu: `sudo apt install libfuse2` (`libfuse2t64` on Ubuntu 24.04+)

## Install

```sh
git clone git@github.com:somethim/packettracer.git
cd packettracer
make install
```

- **Arch**: builds and installs a real pacman package (`packettracer`) with `makepkg`.
- **Any other distro** (Fedora, Debian, ...): installs into `/usr/local` with `sudo`.
  Install for your user only, without sudo: `make install PREFIX=~/.local`.

Packet Tracer then shows up in your launcher as **Cisco Packet Tracer**. Run it from a
terminal with `packettracer`.

## Uninstall

```sh
make uninstall                    # same PREFIX you installed with
make clean                        # remove build leftovers
```

## Updating to a new Packet Tracer version

1. Download the new Ubuntu `.deb` from Cisco NetAcad into this folder.
2. In `PKGBUILD`, update `pkgver`, the `.deb` filename in `source`, and its `sha512sums`
   (`sha512sum <file>.deb`). Reset `pkgrel=1`.
3. `makepkg --printsrcinfo > .SRCINFO`
4. `make upload` to attach the new `.deb` to a GitHub release, then commit and push.
