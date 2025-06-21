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
