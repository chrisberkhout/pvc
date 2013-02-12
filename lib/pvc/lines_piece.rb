module PVC
  class LinesPiece

    class Runner

      def initialize(block, opts)
        @block = block
        @mode = opts[:mode]
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
            new_line = @block.call(line)
            following_piece.stdin.write case @mode
              when :map then new_line
              when :tap then line
              else raise "wrong mode"
            end
          end
        end
      end

      def finish
        @write.close
        @thread.join
        @read.close
      end

    end

    def initialize(block, opts)
      @block = block
      @mode = opts[:mode]
    end

    def runner
      Runner.new(@block, :mode => @mode)
    end

  end
end

