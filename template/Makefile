
# Path to the root folder. Needed to find the latex base files.
ROOTPATH = ../base

# The temporary files of the latex build will not be generated here but in
# BUILDPATH = $(ROOTPATH)/../build/$(BUILDFOLDER).
# The name of the `BUILDFOLDER` variable must be unique within all latex
# documents in this repository. Use the document number  (here `0000`) with
# a short version of the document title. To avoid problems the name should
# not contain any whitespaces.
#
# It is also possible to overwrite BUILDPATH to specify a different folder. In
# that case BUILDFOLDER is ignored.
BUILDFOLDER = template

# Name of the generated document. Make sure that this value matches
# the values from the document tree and the settings in `meta.tex`.
RESULT      = "document/document.pdf"

include $(ROOTPATH)/paper/makefile.latex.mk

