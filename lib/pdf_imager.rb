# Converts a PDF into images for analysis.
# This uses `pdftocairo` tool

class PDFImager
  def initialize(target_path:, format: nil)
    @command = "pdftocairo"
    @format = format || 'jpeg'
    @target_path = target_path
    verify_command!
  end

  def verify_command!
    result = `which #{@command}`
    raise RuntimeError, "`#{@command}` does not seem to be installed" if result.nil? || result == ''
  end

  def digest!(file:)
    `#{@command} #{file} -#{@format} #{@target_path}`
  end
end
