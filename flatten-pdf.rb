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

files = []
failed_check = []
if File.directory?(source_path)
  source_path = source_path[0..-2] if source_path[-1] == '/'
  Dir["#{source_path}/*.pdf"].each{ |pdf_file| files << pdf_file }
else
  files << source_path
end

puts "PDF Processor targeting:"
files.each{ |f| puts "- #{f}" }
puts ""
files.each do |pdf_file|
  workdir = File.dirname(pdf_file)
  output_file = "output/#{File.basename(pdf_file)}"
  image_files = pdf_imager.digest! file: pdf_file
  image_files.each { |file| image_sanitizer.sanitize_image!(file: file) }
  generator = PDFGenerator.new(source_files: image_files, delete_files: true)
  generator.generate!(target_file: output_file)
  failed_check << pdf_file unless PDFChecker.new.pdf_ok?(output_file)
end

if failed_check.any?
  puts "The following files failed validation:"
  failed_check.each{ |f| puts "- #{f}" }
end

puts 'All done!!'
