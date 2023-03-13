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
  `pdftocairo #{path} -#{@image_format} #{target_path}/image`
end

def to_pdf path, target_path, debug = false
  manual_intervention(path) if debug
  puts "- Generating new PDF in #{path}"
  if @image_format == 'png'
    `img2pdf --output #{target_path} #{path}/*.png`
    Dir["#{path}/*.png"].each{ |image| File.delete(image) }
  elsif @image_format == 'jpeg'
    `img2pdf --output #{target_path} #{path}/*.jpg`
    Dir["#{path}/*.jpg"].each{ |image| File.delete(image) }
  end
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

def manual_intervention path
  loop do
    if @image_format == 'png'
      puts `./check-png-images #{path}`
    elsif @image_format == 'jpeg'
      puts `./check-jpg-images #{path}`
    else
      puts "Invalid image_format"
      exist 1
    end

    print 'Recheck images? (y/n)'
    answer = STDIN.gets.chomp
    break if answer == 'n'
    puts "\n\n"
  end
end

puts "PDF Processor targeting:"
files.each{ |f| puts "- #{f}" }
puts ""
debug = false
loop do
  files.each do |pdf_file|
    workdir = File.dirname(pdf_file)
    output_file = "output/#{File.basename(pdf_file)}"
    to_cairo(pdf_file, workdir)
    to_pdf(workdir, output_file, debug)
    output = pdfid(output_file)
    failed_check << pdf_file unless pdfid_ok?(output)
  end

  if failed_check.any?
    puts "The following files failed validation:"
    failed_check.each{ |f| puts "- #{f}" }
    print "Rerun failed with manual interventin? (y/n): "
    answer = STDIN.gets.chomp
    if answer == 'y'
      debug = true
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
