PDF Flattening Tool
===================

This is a simple tool I put up for one specific purpose: PDF flattening and specific cleanup of \AA and \JS byte codes.

The main script does the following actions:

- Convert a PDF to plain images
- Convert the images back to a new PDF file in `output/`
- Run pdfid tool to determine presence of byte codes
- (optional) Rerun files that still have the byte does


### Dependencies

This tool uses `pdftocairo` to convert a PDF file into images and `img2pdf` to spawn a new PDF from the images. Ensure
you have these tools installed on your system. Running:

```
$ sudo apt-get install pdftocairo img2pdf
```

Should do the trick.

The `pdfid` tool is a Python scritp, you probably already have Python installed, but if not, make sure you do.

The main script is done in Ruby, any version from 1.9 and above should be good. Either system Ruby or from RVM/rbenv
should work just ok, the Ruby script is just for orchestration.


### Usage

- Copy the PDF files you want to treat to the `original/` folder
- Run `ruby flatten-pdf.rb original/`
- Check the output of `pdfid` as each file is checked after rebuilt
- If at the end \AA or \JS is present, you can try reconverting with manual intervention

Due to just chance, PNG files can still show up as having \AA and \JS. If a file still have those after a first
run, you can rerun them with manual intervention. In simple words, the process reruns in the same manner, but
before using `img2pdf` it will run the `check-png-images` script to check the images produced by `pdftocairo`.
At this point you will need to manually edit the images to clear the byte codes using an editor.

What I do in this situation, is open the images listed by `check-png-images`, one by one in Gimp, and export
it again as PNG with a different compression level. Then recheck the images, and change the compression again
if not clear. Once the images are cleared, stop the checks and the process will resume to rebuild the PDF and
pass it through `pdfid`. If you don't care about \AA or \JS or any of that, just don't rerun, the final PDFs
should be all flattened. Checking the byte codes is just a minor extra step I have to do often.

The final PDF files should be on `output/` at the end of the process.

### JPEG Output

To change the image format used during the process an additional argument can be passed to the command:

```
ruby flatten-pdf.rb original/ jpeg
```

Instead of:

```
ruby flaten-pdf.rb original/ png
```

The default is `png`. But when using `jpeg`, the image conversion will be done using JPEG format, which
results in smaller images. Depending on the contents of the images, this can be helpful.

### JPEG vs PNG

(Don't quote me on this)

PNG is a great image format, and is quite suitable for high quality/lossless compressed images. However,
the PNG format stores color and pallette information along with the data. This means that for simple designs,
typically done in digital software or renders, PNG offers a great compression ratio, when the number of different
colors is low. Line art, charts, logos, all are great examples for this case.

PNG however will not have good compression ratio in cases where the are lots of colors involved, which is the
typical case of actual photos from cameras. Any typical photo contains a whole lot of different colors.

JPEG, does not save color information as PNG does, applying a different algorithm for compression that in fact,
works on smaller regions of the picture to set a common pattern. These patterns represent the high-level
details of the picture and are not necessary know completely, saving 'which detail pattern' a section of the
picture is rather than 'saving the exact pattern'. For these reason JPEG is better suited for photos, unlike
PNG, and in the case of actual photos, the small artifacts JPEG may produce blend better on the overall image.
Fine details like lines or edges may outstand in a heavily compressed picture. For that reason, line art or
high contrast images, that could be a logo or a chart, will have many artifacts shown on the compressed image.

Use this information to pick one format over the other.