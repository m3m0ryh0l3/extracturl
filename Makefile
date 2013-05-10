#!/usr/bin/make -f
#
#   Copyright information
#
#	Copyright (C) 2013 Kyle Wheeler
#	Copyright (C) 2013 Jari Aalto <jari.aalto@cante.net>
#
#   License BSD-2-Clause (simplified)
#
#	Redistribution and use in source and binary forms, with or without
#	modification, are permitted provided that the following conditions are
#	met:
#
#	1. Redistributions of source code must retain the above copyright
#	   notice, this list of conditions and the following disclaimer.
#
#	2. Redistributions in binary form must reproduce the above copyright
#	   notice, this list of conditions and the following disclaimer in the
#	   documentation and/or other materials provided with the
#	   distribution.
#
#	THIS SOFTWARE IS PROVIDED BY KYLE WHEELER "AS IS" AND ANY EXPRESS OR
#	IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#	DISCLAIMED. IN NO EVENT SHALL KYLE WHEELER OR CONTRIBUTORS BE LIABLE
#	FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
#	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
#	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
#	BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#	WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
#	OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
#	IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#	URL: http://spdx.org/licenses/BSD-2-Clause

ifneq (,)
This makefile requires GNU Make.
endif

PACKAGE		= extract_url
VERSION	       := $(shell ./$(PACKAGE).pl --version | awk '{print $$2}' )

DESTDIR		=
prefix		= /usr
exec_prefix	= $(prefix)
man_prefix	= $(prefix)/share
mandir		= $(man_prefix)/man
bindir		= $(exec_prefix)/bin
sharedir	= $(prefix)/share

BINDIR		= $(DESTDIR)$(bindir)
DOCDIR		= $(DESTDIR)$(sharedir)/doc
LOCALEDIR	= $(DESTDIR)$(sharedir)/locale
SHAREDIR	= $(DESTDIR)$(sharedir)/$(PACKAGE)
LIBDIR		= $(DESTDIR)$(prefix)/lib/$(PACKAGE)
SBINDIR		= $(DESTDIR)$(exec_prefix)/sbin
ETCDIR		= $(DESTDIR)/etc/$(PACKAGE)

# 1 = regular, 5 = conf, 6 = games, 8 = daemons
MANDIR		= $(DESTDIR)$(mandir)
MANDIR1		= $(MANDIR)/man1
MANDIR5		= $(MANDIR)/man5
MANDIR6		= $(MANDIR)/man6
MANDIR8		= $(MANDIR)/man8

INSTALL_OBJS_BIN   = $(PACKAGE)
INSTALL_OBJS_MAN1  = *.1
INSTALL_OBJS_SHARE =
INSTALL_OBJS_ETC   =

INSTALL		= /usr/bin/install
INSTALL_BIN	= $(INSTALL) -m 755
INSTALL_DATA	= $(INSTALL) -m 644
INSTALL_SUID	= $(INSTALL) -m 4755

BIN		= $(PACKAGE)
PL_SCRIPT	= $(BIN).pl

INSTALL_OBJS_BIN   = $(PL_SCRIPT)
INSTALL_OBJS_DOC   = README COPYING
INSTALL_OBJS_MAN   = bin/*.1

XARGS		= xargs xargs --no-run-if-empty
PERL		= perl

manpage = $(PACKAGE).1

# For testing only
instdir = $$(pwd)/tmp

# Rule: all - Generate files from sources
all: doc
	@echo "Version $(VERSION) done. For more information, see 'make help'"

# Rule: help - Display Makefile targets
help:
	@grep -E "^[[:space:]]*# Rule:" Makefile | \
	sed 's/^[[:space:]]*//' | \
	sort

# Rule: clean - Remove temporary files
clean:
	# target: clean
	find .	-name "*[#~]" \
		-o -name "*.\#*" \
		-o -name "*.x~~" \
		-o -name "pod*.tmp" | \
	$(XARGS) rm -f

	rm -rf tmp *.1

# Rule: distclean - Remove everything that can be generated
distclean: clean
	rm -f $(manpage)
	rm -rf $(instdir)

realclean: distclean

$(manpage): $(PL_SCRIPT)
	make -f pod2man.mk \
	PACKAGE=$(PACKAGE) \
	MANPOD=$(PL_SCRIPT) \
	makeman


# Rule: man - Generate or update manual page
man: $(manpage)

doc: man

# Rule: test-pod - Check POD manual page syntax
test-pod:
	podchecker $(PL_SCRIPT)

# Rule: test-perl - Check program syntax
test-perl:
	$(PERL) -cw $(PL_SCRIPT)

# Rule: test - Run all tests
test: test-pod test-perl

install-man: test-pod
	# install-man
	$(INSTALL_BIN) -d $(MANDIR1)
	$(INSTALL_DATA) $(INSTALL_OBJS_MAN1) $(MANDIR1)

install-bin: test-perl
	# target: install-bin - Install programs
	$(INSTALL_BIN) -d $(BINDIR)
	for f in $(INSTALL_OBJS_BIN); \
	do \
		dest=$$(basename $$f | sed -e 's/\.pl$$//' -e 's/\.py$$//' ); \
		$(INSTALL_BIN) $$f $(BINDIR)/$$dest; \
	done

# Rule: install - Standard install. Set DESTDIR for packaging work.
install: install-bin install-man

# Rule: install-test - [maintainer] Dry-run install to tmp/ directory
install-test:
	rm -rf tmp
	make DESTDIR=$(instdir) prefix=/usr install
	find tmp | sort

.PHONY: clean distclean realclean install install-bin install-man

# End of file
