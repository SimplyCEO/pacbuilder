# Makefile for PacBuilder

SHELL = /bin/sh
INSTALL = /bin/install -c
MSGFMT = /usr/bin/msgfmt
SED = /bin/sed
DESTDIR =
bindir = /usr/bin
sysconfdir = /etc
localedir = /usr/share/locale

PROGRAMS = pacbuilder
install: 
	$(INSTALL) -d $(DESTDIR)$(bindir)
	$(INSTALL) -d $(DESTDIR)$(sysconfdir)
	$(INSTALL) -m755 src/pacbuilder $(DESTDIR)$(bindir)/pacbuilder
	$(INSTALL) -m644 etc/pacbuilder.conf $(DESTDIR)$(sysconfdir)/pacbuilder.conf
	for file in po/*.po; \
	do \
	  lang=$$(echo $$file | $(SED) -e 's#.*/\([^/]\+\).po#\1#'); \
	  $(INSTALL) -d $(DESTDIR)$(localedir)/$$lang/LC_MESSAGES; \
	  $(MSGFMT) -o $(DESTDIR)$(localedir)/$$lang/LC_MESSAGES/pacbuilder.mo $$file; \
	done
