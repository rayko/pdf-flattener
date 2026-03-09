# Makes a new PDF file from a set of images
# Uses `img2pdf` tool internally

class PDFGenerator

  def initialize(source_files:, delete_files: nil)
    @command = 'img2pdf'
    @source_files = source_files
    @delete_files = delete_files
    verify_command!
  end

  def verify_command!
    result = `which #{@command}`
    raise RuntimeError, "`#{@command}` does not seem to be installed" if result.nil? || result == ''
  end

  def generate!(target_file:)
    file_list = @source_files.join(' ')
    `#{@command} --output #{target_file} #{file_list}`
    cleanup!
  end

  def cleanup!
    return nil unless @delete_files
    @source_files.each do |file|
      File.delete(file) if File.exist?(file)
    end
  end
end
