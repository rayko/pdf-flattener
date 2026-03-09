require_relative 'lib/pdf_imager'
require_relative 'lib/pdf_generator'
require_relative 'lib/image_sanitizer'

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

###

def to_cairo path, target_path
  puts "- Generating images ..."
  imager = PDFImager.new target_path: "#{target_path}/image", format: @image_format
  imager.digest! file: path
end

def to_pdf path, target_path, debug = false
  manual_intervention(path) if debug
  puts "- Generating new PDF in #{path}"
  if @image_format == 'png'
    files = Dir["#{path}/*.png"]
  elsif @image_format == 'jpeg'
    files = Dir["#{path}/*.jpg"]
  end
  generator = PDFGenerator.new source_files: files, delete_files: true
  generator.generate! target_file: target_path
  puts "- Replaced original file with new PDF: #{target_path}"
end

def pdfid path
  puts "- Running PDFiD ..."
  pdfid_script = 'pdfid/pdfid.py'
  output = `python3 #{pdfid_script} #{path}`
  puts output
  output
end

def pdfid_ok? output
  parsed = output.split("\n").map(&:strip)
  parsed.shift(10)
  check = parsed.map(&:split).map(&:last).map(&:to_i).sum
  check == 0
end

files = []
failed_check = []
if File.directory?(source_path)
  source_path = source_path[0..-2] if source_path[-1] == '/'
  Dir["#{source_path}/*.pdf"].each{ |pdf_file| files << pdf_file }
else
  files << source_path
end

def sanitize_images(source_path)
  processor = ImageSanitizer.new
  Dir["#{source_path}/*.png"].each do |png_file|
    processor.sanitize_image! file: png_file
  end
  Dir["#{source_path}/*.jpg"].each do |jpg_file|
    processor.sanitize_image! file: jpg_file
  end
end

puts "PDF Processor targeting:"
files.each{ |f| puts "- #{f}" }
puts ""
files.each do |pdf_file|
  workdir = File.dirname(pdf_file)
  output_file = "output/#{File.basename(pdf_file)}"
  to_cairo(pdf_file, workdir)
  sanitize_images(workdir)
  to_pdf(workdir, output_file)
  output = pdfid(output_file)
  failed_check << pdf_file unless pdfid_ok?(output)
end

if failed_check.any?
  puts "The following files failed validation:"
  failed_check.each{ |f| puts "- #{f}" }
end

puts 'All done!!'
