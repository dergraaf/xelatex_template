# Copyright (c) 2013, German Aerospace Center (DLR)
# All Rights Reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

BUILDFOLDER ?= .
BUILDPATH   ?= $(ROOTPATH)/../build/$(BUILDFOLDER)

COMMONPATH   = $(ROOTPATH)/common
DOCUMENTPATH = $(ROOTPATH)/paper

LATEX ?= xelatex

MAINFILE    = main

# Additional input folders for pdflatex. The trailing semicolon at the end
# is nessesary to add the default search path!
TEXINPUTS = $(COMMONPATH):$(COMMONPATH)/packages:$(COMMONPATH)/images:$(DOCUMENTPATH):$(DOCUMENTPATH)/images:$(BUILDPATH):$(BUILDPATH)/images:$(BUILDPATH)/rst:$(BUILDPATH)/md:

RST_SRC  = $(wildcard content/*.rst)
RST_SRC += $(wildcard content/*/*.rst)
RST_OUT  = $(RST_SRC:content/%.rst=$(BUILDPATH)/rst/content/%.tex)

MD_SRC  = $(wildcard content/*.md)
MD_SRC += $(wildcard content/*/*.md)
MD_OUT  = $(MD_SRC:content/%.md=$(BUILDPATH)/md/content/%.tex)

all: images index tex

long: images tex index bibtex

configure:
	@-mkdir -p $(BUILDPATH)/images
	@-mkdir -p $(BUILDPATH)/content
	@-mkdir -p $(BUILDPATH)/rst/content
	@-mkdir -p $(BUILDPATH)/md/content

md: $(MD_OUT)
$(BUILDPATH)/md/content/%.tex: content/%.md
	pandoc --from=markdown --to=rst --output="$@.rst" "$<"
	$(COMMONPATH)/rst/document_generator.py "$@.rst" \
		--table-style="booktabs" \
		--tab-width=4 \
		--template="$(COMMONPATH)/rst/template.tex" \
		"$@"

rst: $(RST_OUT)
$(BUILDPATH)/rst/content/%.tex: content/%.rst
	$(COMMONPATH)/rst/document_generator.py "$<" \
		--table-style="booktabs" \
		--tab-width=4 \
		--template="$(COMMONPATH)/rst/template.tex" \
		"$@"

pandoc --from=markdown --to=rst --output=README.rst README.md

preprocess: configure
#	python $(DOCUMENTPATH)/preprocess.py meta.tex $(DOCUMENTPATH)/document_approval.tex.in $(BUILDPATH)/document_approval.tex
	

ifeq ($(OS),Windows_NT)
# Windows
# WARNING: The xelatex -include-directory paramter is a MiKTeX extension and is not available in other packages!
PARAMETER=$(foreach param,$(subst :, ,$(TEXINPUTS)),-include-directory=$(param))
LATEX_PREFIX=
LATEX_POSTFIX=$(PARAMETER)
else
# Linux
LATEX_PREFIX=TEXINPUTS="$(TEXINPUTS)"
LATEX_POSTFIX=
endif

tex: configure md rst preprocess
	@$(LATEX_PREFIX) $(LATEX) $(LATEX_POSTFIX) -output-directory="$(BUILDPATH)" $(MAINFILE).tex
	# Repeat until LaTex has updated all dependencies
	@while (grep -e 'Rerun to get ' -e 'Rerun LaTeX.' $(BUILDPATH)/$(MAINFILE).log) ; do \
		( $(LATEX_PREFIX) $(LATEX) $(LATEX_POSTFIX) -output-directory="$(BUILDPATH)" $(MAINFILE).tex ) ; \
	done
	@cp $(BUILDPATH)/$(MAINFILE).pdf $(RESULT)

bibtex:
	@BSTINPUTS=$(TEXINPUTS) bibtex main

index: configure
	@-cd $(BUILDPATH) && makeindex -s $(MAINFILE).ist -t $(MAINFILE).alg -o $(MAINFILE).acr $(MAINFILE).acn
	@-cd $(BUILDPATH) && makeindex -s $(MAINFILE).ist -t $(MAINFILE).glg -o $(MAINFILE).gls $(MAINFILE).glo
	@-cd $(BUILDPATH) && makeindex -s $(MAINFILE).ist -t $(MAINFILE).slg -o $(MAINFILE).syi $(MAINFILE).syg

view:
	xdg-open $(RESULT) &

spell:
	$(COMMONPATH)/spellcheck.sh aspell.dict content/*.tex

include $(COMMONPATH)/makefile.images.mk

clean:
	@$(RM) -r $(BUILDPATH)

distclean: clean
	@$(RM) $(RESULT)

.PHONY: index preprocess clean tex bibtex spell view images

