# Converts a PDF into images for analysis, writing the images at the same location
# as the original PDF
# This uses `pdftocairo` tool

class PDFImager
  def initialize(format: nil)
    @command = "pdftocairo"
    @format = format || 'jpeg'
    verify_command!
  end

  def verify_command!
    result = `which #{@command}`
    raise RuntimeError, "`#{@command}` does not seem to be installed" if result.nil? || result == ''
  end

  def digest!(file:)
    raise StandardError, "Unsupported format #{@format}" unless @format =~ /png|jpeg/i
    target_dir = File.dirname(File.absolute_path(file))
    `#{@command} #{file} -#{@format} #{target_dir}/image`
    return Dir["#{target_dir}/*.png"] if @format =~ /png/i
    return Dir["#{target_dir}/*.jpg"] if @format =~ /jpeg/i
  end
end
