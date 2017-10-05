# Makefile for obarun-libs

VERSION = $$(git describe --tags| sed 's/^v//;')
PKGNAME = obarun-libs

BINDIR = /usr/bin

SCRIPTS = $$(find lib/ -type f)
FILES = util.sh

install: 
	
	for i in $(FILES) $(SCRIPTS); do \
		sed -i 's,@BINDIR@,$(BINDIR),' $$i; \
	done
	
	install -Dm 0755 util.sh $(DESTDIR)/usr/lib/obarun/util.sh
	
	for i in $(SCRIPTS); do \
		install -Dm 0755 $$i $(DESTDIR)/usr/lib/obarun/$$i; \
	done
	
	install -Dm644 LICENSE $(DESTDIR)/usr/share/licenses/$(PKGNAME)/LICENSE

version:
	@echo $(VERSION)
	
.PHONY: install version 
