PROJECT = pacbuilder
INSTALL = /bin/install -c
bindir = /usr/bin
sysconfdir = /etc

all:
	@printf "No inputs given.\n\n"
	@printf "Usage:\n"
	@printf "  directories            create '$(bindir)', '$(sysconfdir)', and '$(sysconfdir)/$(PROJECT).d'.\n"
	@printf "  install-binary         install only '$(PROJECT)' binary file.\n"
	@printf "  install-configuration  install only '$(PROJECT).conf' configuration file.\n"
	@printf "  install-mirrorlist     install only $(PROJECT) 'mirrorlists' file.\n"
	@printf "  install-modules        install all $(PROJECT) modules.\n"
	@printf "  install                install $(PROJECT) entirely.\n"

directories:
	$(INSTALL) -d $(DESTDIR)$(bindir)
	$(INSTALL) -d $(DESTDIR)$(sysconfdir)
	$(INSTALL) -d $(DESTDIR)$(sysconfdir)/$(PROJECT).d
	$(INSTALL) -d $(DESTDIR)$(sysconfdir)/$(PROJECT).d/modules

install-binary: directories
	$(INSTALL) -m755 src/$(PROJECT) $(DESTDIR)$(bindir)/$(PROJECT)

install-configuration: directories
	$(INSTALL) -m644 assets/$(PROJECT).conf $(DESTDIR)$(sysconfdir)/$(PROJECT).conf

install-mirrorlist: directories
	$(INSTALL) -m644 assets/$(PROJECT).d/mirrorlist $(DESTDIR)$(sysconfdir)/$(PROJECT).d/mirrorlist

install-modules: directories
	$(INSTALL) -m755 src/modules/core.sh $(DESTDIR)$(sysconfdir)/$(PROJECT).d/modules
	$(INSTALL) -m755 src/modules/information.sh $(DESTDIR)$(sysconfdir)/$(PROJECT).d/modules
	$(INSTALL) -m755 src/modules/project.sh $(DESTDIR)$(sysconfdir)/$(PROJECT).d/modules
	$(INSTALL) -m755 src/modules/tools.sh $(DESTDIR)$(sysconfdir)/$(PROJECT).d/modules
	$(INSTALL) -m755 src/modules/constructor.sh $(DESTDIR)$(sysconfdir)/$(PROJECT).d/modules
	$(INSTALL) -m755 src/modules/manager.sh $(DESTDIR)$(sysconfdir)/$(PROJECT).d/modules

install: install-binary install-configuration install-mirrorlist install-modules

