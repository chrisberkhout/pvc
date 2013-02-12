module PVC
  class LinesMapPiece

    class Runner

      def initialize(block)
        @block = block
        @read, @write = IO.pipe
        @read.close_on_exec = true
        @write.close_on_exec = true
      end

      def stdin
        @write
      end

      def start(following_piece)
        @return = nil
        @thread = Thread.new do
          @read.each_line do |line|
            following_piece.stdin.write @block.call(line)
          end
        end
      end

      def finish
        @write.close
        @thread.join
        @read.close
      end

    end

    def initialize(block)
      @block = block
    end

    def runner
      Runner.new(@block)
    end

  end
end

