# pod2man.mk -- Makefile portion to convert *.pod files to manual pages
#
#   Copyright information
#
#	Copyright (C) 2008-2013 Jari Aalto
#
#   License BSD-2-Clause (simplified)
#
#       Redistribution and use in source and binary forms, with or
#       without modification, are permitted provided that the
#       following conditions are met:
#
#       1. Redistributions of source code must retain the above copyright
#          notice, this list of conditions and the following disclaimer.
#
#       2. Redistributions in binary form must reproduce the above
#          copyright notice, this list of conditions and the following
#          disclaimer in the documentation and/or other materials
#          provided with the distribution.
#
#       THIS SOFTWARE IS PROVIDED BY {{THE COPYRIGHT HOLDERS AND
#       CONTRIBUTORS}} "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
#       INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#       MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#       DISCLAIMED. IN NO EVENT SHALL {{THE COPYRIGHT HOLDER OR
#       CONTRIBUTORS}} BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#       SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
#       NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#       LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
#       HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
#       CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
#       OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
#       EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#	See <http://spdx.org/licenses/BSD-2-Clause>.
#
#   Description
#
#	Convert *.pod files to manual pages. Add this to Makefile:
#
#	    PACKAGE = package
#
#	    man:
#		    make -f pod2man.mk PACKAGE=$(PACKAGE) makeman
#
#	    build: man

ifneq (,)
    This makefile requires GNU Make.
endif

# This variable *must* be set when called
PACKAGE		?= package

# Optional variables to set
MANSECT		?= 1
PODCENTER	?= User Commands
PODDATE		?= $$(date "+%Y-%m-%d")

# Directories
MANSRC		?=
MANDEST		?= $(MANSRC)

MANPOD		?= $(MANSRC)$(PACKAGE).$(MANSECT).pod
MANPAGE		?= $(MANDEST)$(PACKAGE).$(MANSECT)

POD2MAN		?= pod2man
POD2MAN_FLAGS	?= --utf8

makeman: $(MANPAGE)

$(MANPAGE): $(MANPOD)
	# make target - create manual page from a *.pod page
	podchecker $(MANPOD)
	LC_ALL= LANG=C $(POD2MAN) $(POD2MAN_FLAGS) \
		--center="$(PODCENTER)" \
		--date="$(PODDATE)" \
		--name="$(PACKAGE)" \
		--section="$(MANSECT)" \
		$(MANPOD) \
	| sed 's,[Pp]erl v[0-9.]\+,$(PACKAGE),' \
	  > $(MANPAGE) && \
	rm -f pod*.tmp

# End of of Makefile part
