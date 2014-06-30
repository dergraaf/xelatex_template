
# Path to the doc root folder. Needed to find the latex configuration files.
ROOTFOLDER = .

# The temporary files of the latex build will not be generated here but in
# $(ROOTFOLDER)/build/$(BUILDFOLDER).
# The name of the `BUILDFOLDER` variable must be unique within all latex
# documents in this repository. To avoid problems the name should
# not contain any whitespaces.
BUILDFOLDER = template

# Name of the generated document. Make sure that this value matches
# the values from the document tree and the settings in `meta.tex`.
RESULT      = "document/template.pdf"

MAINFILE    = main
CONFIGURATION_FOLDER = $(ROOTFOLDER)/.

include $(CONFIGURATION_FOLDER)/makefile.latex.mk
