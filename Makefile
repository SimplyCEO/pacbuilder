INSTALL = /bin/install -c
bindir = /usr/bin
sysconfdir = /etc/pacbuilder.d

install: 
	$(INSTALL) -d $(DESTDIR)$(bindir)
	$(INSTALL) -d $(DESTDIR)$(sysconfdir)
	$(INSTALL) -m755 src/pacbuilder $(DESTDIR)$(bindir)/pacbuilder
	$(INSTALL) -m644 src/pacbuilder.d/mirrorlist $(DESTDIR)$(sysconfdir)/mirrorlist
