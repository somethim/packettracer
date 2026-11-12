# Cisco Packet Tracer installer

Installs Cisco Packet Tracer with a `packettracer` command, an app-launcher entry and an icon.
The Cisco `.deb` is not stored in git (it is ~400 MB, over GitHub's 100 MB file limit); it is
attached to this repo's [GitHub release](https://github.com/somethim/packettracer/releases)
and downloaded with `curl` by `make install`.

## Requirements

- `git`, `make`, `curl`, `ar` (binutils), `tar`, `xz`
- FUSE 2 to run the AppImage:
  - Arch: `fuse2` (pulled in automatically)
  - Fedora: `sudo dnf install fuse-libs`
  - Debian/Ubuntu: `sudo apt install libfuse2` (`libfuse2t64` on Ubuntu 24.04+)

## Install

```sh
git clone https://github.com/somethim/packettracer.git
cd packettracer
make install
```

- **Arch**: builds and installs a real pacman package (`packettracer`) with `makepkg`.
- **Any other distro** (Fedora, Debian, ...): installs into `/usr/local` with `sudo`.
  Install for your user only, without sudo: `make install PREFIX=~/.local`.

Packet Tracer then shows up in your launcher as **Cisco Packet Tracer**. Run it from a
terminal with `packettracer`.

If you already have the `.deb` from Cisco NetAcad, drop it in this folder first and
`make install` uses it instead of downloading.

## Uninstall

```sh
make uninstall                    # same PREFIX you installed with
make clean                        # remove build leftovers
```

## Maintainer steps (run these yourself)

### Make the repo public

The download in `make install` only works without a login once the repo is public.

1. Open https://github.com/somethim/packettracer/settings
2. Scroll to **Danger Zone** → **Change repository visibility** → **Change to public**, and confirm.
3. Check the download works logged out:
   `curl -fIL https://github.com/somethim/packettracer/releases/download/v9.0.1/CiscoPacketTracer_901_Ubuntu_64bit.deb`

Note: Cisco's EULA restricts redistributing Packet Tracer. A public release makes the `.deb`
downloadable by anyone.

### Release a new Packet Tracer version

1. Download the new Ubuntu `.deb` from Cisco NetAcad into this folder.
2. In `PKGBUILD`, update `pkgver`, the `.deb` filename in `source`, and its `sha512sums`
   (`sha512sum <file>.deb`). Reset `pkgrel=1`.
3. Regenerate metadata, commit and push:
   ```sh
   makepkg --printsrcinfo > .SRCINFO
   git commit -m "chore(release): update to <version>" -- PKGBUILD .SRCINFO
   git push
   ```
4. Open https://github.com/somethim/packettracer/releases/new, set the tag to `v<pkgver>`
   (e.g. `v9.0.2`), attach the `.deb`, and publish.
