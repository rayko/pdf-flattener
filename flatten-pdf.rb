# flatten-pdf.rb
# Small script that automatizes a couple of system tools to 'flatten' a PDF. By
# flattening, we mean to convert each page of the input PDF into an image file,
# either PNG or JPEG, run some checks and re-converts if necessary on each image,
# and pack all the iamges into a new PDF.
#
# This process ensures removing any code or logic coming from the original PDF
# file that might be risky for users when opening them, like ActiveForms or
# any JavaScript original contained.
#
# This is specifically tailored to pass PDFId checks on the resultant PDF file.
#
# To run these, the system needs to have a couple of tools available:
# - pdftocairo > Convert PDF to images
# - img2pdf > Pack a collection of images as a PDF file
# - convert > ImageMagick conversion tool or similar package that bundles `convert`
# - python3 > Required by PDFId tool bundled
#
# How to use?
# The project includes an `original/` and `output/` dir. Place the PDF files to
# process in `original/` dir, and run:
# `ruby flatten-pdf.rb original/ jpeg`
#
# You can use `png` instead of `jpeg` to use PNG format instead. By default, if this
# argument is omitted, JPEG will be used, since it results in smaller images.
#
# Once the process is done, all the processes PDFs will be placed at `output/` dir.
#
# If you want to skip the PDFId on the output PDF, simply set the envar `SKIP_PDFID`
# to true:
# `SKIP_PDFID=true ruby flaten-pdf.rb original/ jpeg`

require_relative 'lib/pdf_imager'
require_relative 'lib/pdf_generator'
require_relative 'lib/image_sanitizer'
require_relative 'lib/pdf_checker'

source_path = ARGV[0]
@image_format = ARGV[1] || 'jpeg'

skip_pdfid = ENV['SKIP_PDFID'] == 'true'

if source_path.nil? || source_path == ''
  puts 'No file provided'
  exit 1
end

unless %[jpeg png].include?(@image_format)
  puts "Specified image format '#{@image_format}' is not supported"
  exit 1
end

pdf_imager = PDFImager.new(format: @image_format)
image_sanitizer = ImageSanitizer.new
files = Dir["#{source_path}*.pdf"]

puts "PDF Processor targeting:"
files.each{ |f| puts "- #{f}" }
puts ""
files.each do |pdf_file|
  puts "Processing #{pdf_file} ..."
  workdir = File.dirname(pdf_file)
  output_file = "output/#{File.basename(pdf_file)}"
  image_files = pdf_imager.digest! file: pdf_file
  image_files.each { |file| image_sanitizer.sanitize_image!(file: file) }
  generator = PDFGenerator.new(source_files: image_files, delete_files: true)
  generator.generate!(target_file: output_file)
  unless skip_pdfid
    unless PDFChecker.new.pdf_ok?(output_file)
      puts "File #{pdf_file} has failed PDFID checks!!"
    end
  end
  puts "Processed #{pdf_file}\n\n"
end

puts 'All done!!'
