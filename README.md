PDF Flattening Tool
===================

This is a simple tool I put up for one specific purpose: PDF flattening and specific cleanup of \AA and \JS byte codes.

The main script does the following actions:

- Convert a PDF to plain images (either PNG or JPEG)
- Check byte codes and re-convert each image if needed
- Convert the images back to a new PDF file in `output/`
- Run pdfid tool to determine presence of byte codes


### Dependencies

Some system tools are needed to run this:

- `pdftocairo`

Converts a PDF onto images representing the pages of the PDF.

For Debian/Ubuntu systems this should install it:

```
$ sudo apt-get install poppler-utils
```

Experimental repositories might be needed

- `img2pdf`

Packs a collections of images into a PDF file.

For Debian/Ubuntu systems, this should install it:

```
$ sudo apt-get install img2pdf
```

- `convert`

Image processing tool to convert images into different formats. This typically comes
from ImageMagick package, but other packages may include this tool as well.

For Debian/Ubuntu systems, this should install it:

```
sudo apt-get install imagemagick
```

- `python3`

Used to run the optional PDFId tool bundled. Should be available on the system already.

### Usage

- Copy the PDF files you want to treat to the `original/` folder
- Run `ruby flatten-pdf.rb original/`

Once the process finishes, the output files should be available in `./output/`. By default,
the process will use JPEG for the image formats, but PNG can be used instead like so:

```
ruby flaten-pdf.rb original/ png
```

Additionally, it can be possible to completely skip the PDFId check, which can be slow to
complete. To do this, simply set `SKIP_PDFID` envar to `true`:

```
SKIP_PDFID=true ruby flatten-pdf.rb original/
```

### JPEG vs PNG

(Don't quote me on this)

PNG is a great image format, and is quite suitable for high quality/lossless compressed images. However,
the PNG format stores color and pallette information along with the data. This means that for simple designs,
typically done in digital software or renders, PNG offers a great compression ratio, when the number of different
colors is small. Line art, charts, logos, all are great examples for this case.

PNG however will not have good compression ratio in cases where the are lots of colors involved, which is the
typical case of actual photos from cameras. Any typical photo contains a whole lot of different colors.

JPEG, does not save color information as PNG does, applying a different algorithm for compression that in fact,
works on regions of the picture that are similar, to set a common pattern. These patterns represent the high-level
details of the picture and are not necessary know completely, saving 'which detail pattern' a section of the
picture is rather than 'saving the exact pattern'. For these reason JPEG is better suited for photos, unlike
PNG, and in the case of actual photos, the small artifacts JPEG may produce blend better on the overall image.
Fine details like lines or edges may be noticeable in a heavily compressed picture. For that reason, line art or
high contrast images, which could be a logo or a chart, will show artifacts on the compressed image.

Use this information to pick one format over the other.
