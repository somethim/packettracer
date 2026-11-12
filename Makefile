# The Cisco .deb lives as a release asset on a private GitHub repo (needs `gh auth login`).
REPO   ?= somethim/packettracer
PREFIX ?= /usr/local
VER    := $(shell sed -n 's/^pkgver=//p' PKGBUILD 2>/dev/null)
DEB    := $(shell sed -n "s|.*local://\([^']*\)'.*|\1|p" PKGBUILD 2>/dev/null)
SUDO   ?= $(if $(filter $(HOME)/%,$(PREFIX)),,sudo)
APPDIR  = $(DESTDIR)$(PREFIX)/lib/packettracer
SHARE   = $(DESTDIR)$(PREFIX)/share
DESKTOPS = CiscoPacketTracer CiscoPacketTracerPtsa

.PHONY: install install-generic files fetch upload uninstall clean

# Arch: build a real pacman package. Everything else: install-generic.
install: $(DEB)
ifneq ($(shell command -v makepkg),)
	makepkg -sif --noconfirm
else
	$(MAKE) install-generic
endif

install-generic: squashfs-root
	$(SUDO) $(MAKE) files PREFIX=$(PREFIX)

fetch: $(DEB)

$(DEB):
	gh release download v$(VER) -R $(REPO) -p $(DEB)

data.tar.xz: $(DEB)
	ar x $(DEB) data.tar.xz

# Pull the AppImage out of the .deb, and the icon + desktop files out of the AppImage.
opt/pt/packettracer.AppImage: data.tar.xz
	tar xJf data.tar.xz ./opt/pt/packettracer.AppImage

squashfs-root: opt/pt/packettracer.AppImage
	./opt/pt/packettracer.AppImage --appimage-extract app.png >/dev/null
	./opt/pt/packettracer.AppImage --appimage-extract '*.desktop' >/dev/null

# Shared by install-generic and PKGBUILD's package().
files: opt/pt/packettracer.AppImage squashfs-root
	install -Dm755 opt/pt/packettracer.AppImage $(APPDIR)/packettracer.AppImage
	install -d $(DESTDIR)$(PREFIX)/bin
	ln -sf $(PREFIX)/lib/packettracer/packettracer.AppImage $(DESTDIR)$(PREFIX)/bin/packettracer
	install -Dm644 squashfs-root/app.png $(SHARE)/icons/hicolor/48x48/apps/packettracer.png
	install -d $(SHARE)/applications
	for d in $(DESKTOPS); do \
		sed -e 's|@EXEC_PATH@|$(PREFIX)/bin/packettracer|' -e 's|^Icon=.*|Icon=packettracer|' \
			squashfs-root/$$d-*.desktop > $(SHARE)/applications/$$d.desktop; \
	done

# New version: put the new .deb here, bump pkgver + source + sha512sums in PKGBUILD, then `make upload`.
upload:
	gh release create v$(VER) $(DEB) -R $(REPO) -t "Packet Tracer $(VER)" -n "Cisco .deb used by PKGBUILD"

uninstall:
ifneq ($(shell command -v pacman),)
	sudo pacman -R packettracer
else
	$(SUDO) rm -f $(DESTDIR)$(PREFIX)/bin/packettracer $(SHARE)/icons/hicolor/48x48/apps/packettracer.png
	$(SUDO) rm -f $(foreach d,$(DESKTOPS),$(SHARE)/applications/$(d).desktop)
	$(SUDO) rm -rf $(APPDIR)
endif

clean:
	rm -rf src pkg opt squashfs-root
	rm -f data.tar.xz *.pkg.tar.*
