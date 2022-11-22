source_path = ARGV[0]

if source_path.nil? || source_path == ''
  puts 'No file provided'
  exit 1
end

###

def to_cairo path, target_path
  puts "- Generating images ..."
  `pdftocairo #{path} -png #{target_path}/image`
end

def to_pdf path, target_path
  puts "- Generating new PDF in #{path}"
  `img2pdf --output #{target_path} #{path}/*.png`
  Dir["#{path}/*.png"].each{ |image| File.delete(image) }
  puts "- Replaced original file with new PDF: #{target_path}"
end

def pdfid path
  puts "- Running PDFiD ..."
  pdfid_script = 'pdfid/pdfid.py'
  output = `python #{pdfid_script} #{path}`
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

puts "PDF Processor targeting:"
files.each{ |f| puts "- #{f}" }
puts ""

loop do
  files.each do |pdf_file|
    workdir = File.dirname(pdf_file)
    output_file = "output/#{File.basename(pdf_file)}"
    to_cairo(pdf_file, workdir)
    to_pdf(workdir, output_file)
    output = pdfid(output_file)
    failed_check << pdf_file unless pdfid_ok?(output)
  end

  if failed_check.any?
    puts "The following files failed validation:"
    failed_check.each{ |f| puts "- #{f}" }
    print "Rerun failed? (y/n): "
    answer = STDIN.gets.chomp
    if answer == 'y'
      puts ""
      puts "Rerunning files:"
      failed_check.each{ |f| puts "- #{f}" }
      files = failed_check
      failed_check = []
    else
      break
    end
  else
    break
  end
end

puts 'All done!!'
