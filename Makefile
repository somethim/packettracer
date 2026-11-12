# The Cisco .deb lives as a release asset on a private GitHub repo (needs `gh auth login`).
REPO ?= somethim/packettracer
VER  := $(shell bash -c '. ./PKGBUILD; echo $$pkgver')
DEB  := $(shell sed -n "s|.*local://\([^']*\)'.*|\1|p" PKGBUILD)

.PHONY: install fetch upload uninstall clean

install: $(DEB)
	makepkg -sif --noconfirm

fetch: $(DEB)

$(DEB):
	gh release download v$(VER) -R $(REPO) -p $(DEB)

# New version: put the new .deb here, bump pkgver + sha512sums in PKGBUILD, then `make upload`.
upload:
	gh release create v$(VER) $(DEB) -R $(REPO) -t "Packet Tracer $(VER)" -n "Cisco .deb used by PKGBUILD"

uninstall:
	sudo pacman -R packettracer

clean:
	rm -rf src pkg
	rm -f *.pkg.tar.*
