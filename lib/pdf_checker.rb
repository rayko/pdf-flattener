# Runs PDFId tool (bundled with this tool), to double check PDF outputs.
# Requires `python3` or `python` to be present.

class PDFChecker
  def initialize
    @command = 'python3'
    @pdfid_path = './pdfid'
    verify_command!
  end

  def verify_command!
    result = `which #{@command}`
    raise RuntimeError, "`#{@command}` does not seem to be installed" if result.nil? || result == ''
  end

  def pdf_ok?(file)
    output = `#{@command} #{@pdfid_path}/pdfid.py #{file}`
    puts output
    parsed = output.split("\n").map(&:strip)
    parsed.shift(10)
    check = parsed.map(&:split).map(&:last).map(&:to_i).sum
    check == 0
  end

end
