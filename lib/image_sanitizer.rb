# Sanitizes images by checking some offending bytes. If any offending bytes
# are present, it will reconvert the image until the bytes are gone.
# Uses `convert` command internally, from ImageMagik or similar.

class ImageSanitizer

  def initialize
    @command = 'convert'
    @offending_bytes = ["\AA", "\JS"]
    verify_command!
  end

  def verify_command!
    result = `which #{@command}`
    raise RuntimeError, "`#{@command}` does not seem to be installed" if result.nil? || result == ''
  end

  def sanitize_image!(file:)
    return sanitize_png(file) if file =~ /\.png/i
    return sanitize_jpeg(file) if file =~ /\.jpg/i
    raise StandardError, "Unsupported format for #{file}"
  end

  private

  def has_offending_bytes?(file)
    @offending_bytes.each do |txt|
      result = `grep -al '/#{txt}' #{file}`
      return true unless result.nil? || result == ''
    end
    false
  end

  def sanitize_png(file)
    compression = 9
    while has_offending_bytes?(file)
      compression -= 1
      `convert #{file} -quality #{compression} #{file}`
      puts "Re-convert #{file} with Q #{compression}"
    end
  end

  def sanitize_jpeg(file)
    quality = 90
    while has_offending_bytes?(file)
      quality -= 1
      `convert #{file} -quality #{quality} #{file}`
      puts "Re-convert #{file} with Q #{quality}"
    end
  end
end
