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

IMAGE_SOURCE ?= image_sources
IMAGE_DEST   ?= $(BUILDPATH)/images

IMAGES_PDF_SRC  = $(wildcard $(IMAGE_SOURCE)/*.pdf)
IMAGES_PDF_SRC += $(wildcard $(IMAGE_SOURCE)/*/*.pdf)
IMAGES_PDF_OUT  = $(IMAGES_PDF_SRC:$(IMAGE_SOURCE)/%.pdf=$(IMAGE_DEST)/%.pdf)

IMAGES_SVG_CROP_SRC  = $(wildcard $(IMAGE_SOURCE)/*.crop.svg)
IMAGES_SVG_CROP_SRC += $(wildcard $(IMAGE_SOURCE)/*/*.crop.svg)
IMAGES_SVG_CROP_OUT  = $(IMAGES_SVG_CROP_SRC:$(IMAGE_SOURCE)/%.crop.svg=$(IMAGE_DEST)/%.pdf)

# Select all files ending in *.svg and remove all SVG files which are already
# in the CROP section
IMAGES_SVG_SRC  = $(filter-out $(IMAGES_SVG_CROP_SRC), $(wildcard $(IMAGE_SOURCE)/*.svg))
IMAGES_SVG_SRC += $(filter-out $(IMAGES_SVG_CROP_SRC), $(wildcard $(IMAGE_SOURCE)/*/*.svg))
IMAGES_SVG_OUT  = $(IMAGES_SVG_SRC:$(IMAGE_SOURCE)/%.svg=$(IMAGE_DEST)/%.pdf)

IMAGES_TEX_SRC  = $(wildcard $(IMAGE_SOURCE)/*.tex)
IMAGES_TEX_SRC += $(wildcard $(IMAGE_SOURCE)/*/*.tex)
IMAGES_TEX_OUT  = $(IMAGES_TEX_SRC:$(IMAGE_SOURCE)/%.tex=$(IMAGE_DEST)/%.pdf)

# Find only subfolders of the '$(IMAGE_SOURCE)' folder, ignoring any subversion
# related files or folders
IMAGE_FOLDER_SRC = $(shell find $(IMAGE_SOURCE) -mindepth 1 -type d -not -iwholename '*.svn/*' -not -iwholename '*.svn')
IMAGE_FOLDER_OUT = $(IMAGE_FOLDER_SRC:$(IMAGE_SOURCE)/%=$(IMAGE_DEST)/%)

# Avoid an error of mkdir if '$(IMAGE_SOURCE)' has no subfolders by leting it
# recreate the image folder.
ifeq ($(strip $(IMAGE_FOLDER_OUT)),)
IMAGE_FOLDER_OUT = $(IMAGE_DEST)
endif

# If the '$(IMAGE_SOURCE)' folder has no subfolders the argument list for
# 'mkdir' is empty which causes make to fail. Therefore any error
# of 'mkdir' is silently ignored here. 
image_folder: $(IMAGE_FOLDER_SRC)
	@-mkdir -p $(IMAGE_FOLDER_OUT)

images_pdf: $(IMAGES_PDF_OUT)
$(IMAGE_DEST)/%.pdf: $(IMAGE_SOURCE)/%.pdf
	inkscape --verb=FitCanvasToDrawing -D --export-pdf="$@" "$<"

# Export the area of the page
images_svg: $(IMAGES_SVG_OUT)
$(IMAGE_DEST)/%.pdf: $(IMAGE_SOURCE)/%.svg
	inkscape -C --export-pdf="$@" "$<"

# Export only the area of the drawing (out cropping)
images_svg_crop: $(IMAGES_SVG_CROP_OUT)
$(IMAGE_DEST)/%.pdf: $(IMAGE_SOURCE)/%.crop.svg
	inkscape --verb=FitCanvasToDrawing -D --export-pdf="$@" "$<"

IMAGE_TEXINPUTS=$(COMMONPATH)/packages:
IMAGE_LATEX ?= pdflatex

ifeq ($(OS),Windows_NT)
# Windows
# WARNING: The xelatex -include-directory paramter is a MiKTeX extension and is not available in other packages!
IMGAGE_LATEX_PREFIX=
IMGAGE_LATEX_POSTFIX=$(foreach param,$(subst :, ,$(IMAGE_TEXINPUTS)),-include-directory=$(param))
else
# Linux
IMGAGE_LATEX_PREFIX=TEXINPUTS=TEXINPUTS=$(IMAGE_TEXINPUTS)
IMGAGE_LATEX_POSTFIX=
endif

images_tex: $(IMAGES_TEX_OUT)
$(IMAGE_DEST)/%.pdf: $(IMAGE_SOURCE)/%.tex
	 $(IMAGE_LATEX_PREFIX) $(IMAGE_LATEX) $(IMAGE_LATEX_POSTFIX) -output-directory=$(dir $@) -shell-escape $<

images: configure image_folder images_pdf images_svg_crop images_svg images_tex

.PHONY: image_folder

