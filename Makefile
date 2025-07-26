INSTALL = /bin/install -c
bindir = /usr/bin
sysconfdir = /etc

install: 
	$(INSTALL) -d $(DESTDIR)$(bindir)
	$(INSTALL) -d $(DESTDIR)$(sysconfdir)
	$(INSTALL) -d $(DESTDIR)$(sysconfdir)/pacbuilder.d
	$(INSTALL) -m644 assets/pacbuilder.conf $(DESTDIR)$(sysconfdir)/pacbuilder.conf
	$(INSTALL) -m644 assets/pacbuilder.d/mirrorlist $(DESTDIR)$(sysconfdir)/pacbuilder.d/mirrorlist
	$(INSTALL) -m755 src/pacbuilder $(DESTDIR)$(bindir)/pacbuilder
