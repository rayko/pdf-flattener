require_relative 'lib/pdf_imager'
require_relative 'lib/pdf_generator'
require_relative 'lib/image_sanitizer'
require_relative 'lib/pdf_checker'

source_path = ARGV[0]
@image_format = ARGV[1] || 'png'

if source_path.nil? || source_path == ''
  puts 'No file provided'
  exit 1
end

unless %[jpeg png].include?(@image_format)
  puts "Specified image format '#{@image_format}' is not supported"
  exist 1
end

pdf_imager = PDFImager.new(format: @image_format)
image_sanitizer = ImageSanitizer.new

###

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
  unless PDFChecker.new.pdf_ok?(output_file)
    puts "File #{pdf_file} has failed PDFID checks!!"
  end
  puts "Processed #{pdf_file}\n"
end


puts 'All done!!'
