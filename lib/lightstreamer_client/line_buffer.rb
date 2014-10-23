module Lightstreamer
  class LineBuffer
    NEWLINE = "\r\n"

    attr_accessor :buffer, :callback

    def initialize &block
      buffer = ""
      callback = block
    end

    def << chunk
      buffer += chunk

      while buffer.include? NEWLINE
        line, content = content.split NEWLINE, 2

        callback line
      end
    end
  end
end
