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

IMAGES_PDF_SRC  = $(wildcard image_sources/*.pdf)
IMAGES_PDF_SRC += $(wildcard image_sources/*/*.pdf)
IMAGES_PDF_OUT  = $(IMAGES_PDF_SRC:image_sources/%.pdf=$(BUILDPATH)/images/%.pdf)

IMAGES_SVG_CROP_SRC  = $(wildcard image_sources/*.crop.svg)
IMAGES_SVG_CROP_SRC += $(wildcard image_sources/*/*.crop.svg)
IMAGES_SVG_CROP_OUT  = $(IMAGES_SVG_CROP_SRC:image_sources/%.crop.svg=$(BUILDPATH)/images/%.pdf)

# remove all SVG files which are already in the CROP section
IMAGES_SVG_SRC  = $(filter-out $(IMAGES_SVG_CROP_SRC), $(wildcard image_sources/*.svg))
IMAGES_SVG_SRC += $(filter-out $(IMAGES_SVG_CROP_SRC), $(wildcard image_sources/*/*.svg))
IMAGES_SVG_OUT  = $(IMAGES_SVG_SRC:image_sources/%.svg=$(BUILDPATH)/images/%.pdf)

IMAGES_TEX_SRC  = $(wildcard image_sources/*.tex)
IMAGES_TEX_SRC += $(wildcard image_sources/*/*.tex)
IMAGES_TEX_OUT  = $(IMAGES_TEX_SRC:image_sources/%.tex=$(BUILDPATH)/images/%.pdf)

# Find only subfolders of the 'image_sources' folder, ignoring any subversion
# related files or folders
IMAGE_FOLDER_SRC = $(shell find image_sources -mindepth 1 -type d -not -iwholename '*.svn/*' -not -iwholename '*.svn')
IMAGE_FOLDER_OUT = $(IMAGE_FOLDER_SRC:image_sources/%=$(BUILDPATH)/images/%)

# If the 'image_sources' folder has no subfolders the argument list for
# 'mkdir' is empty which causes make to fail. Therefore any error
# of 'mkdir' is silently ignored here. 
image_folder: $(IMAGE_FOLDER_SRC)
	@-mkdir -p $(IMAGE_FOLDER_OUT)

images_pdf: $(IMAGES_PDF_OUT)
$(BUILDPATH)/images/%.pdf: image_sources/%.pdf
	inkscape --verb=FitCanvasToDrawing -D --export-pdf="$@" "$<"

# Export the area of the page
images_svg: $(IMAGES_SVG_OUT)
$(BUILDPATH)/images/%.pdf: image_sources/%.svg
	inkscape -C --export-pdf="$@" "$<"

# Export only the area of the drawing (out cropping)
images_svg_crop: $(IMAGES_SVG_CROP_OUT)
$(BUILDPATH)/images/%.pdf: image_sources/%.crop.svg
	inkscape --verb=FitCanvasToDrawing -D --export-pdf="$@" "$<"

IMAGE_TEXINPUTS=$(CONFIGURATION_FOLDER)/packages:

images_tex: $(IMAGES_TEX_OUT)
$(BUILDPATH)/images/%.pdf: image_sources/%.tex
	TEXINPUTS=$(IMAGE_TEXINPUTS) pdflatex -output-directory=$(dir $@) -shell-escape $<

images: configure image_folder images_pdf images_svg_crop images_svg images_tex

.PHONY: image_folder

