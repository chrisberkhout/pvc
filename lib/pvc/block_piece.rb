module PVC
  class BlockPiece

    class Runner

      def initialize(&block)
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
          @return = @block.call(@read, following_piece.stdin)
        end
      end

      def finish
        @write.close
        @thread.join
        @read.close
      end

      attr_reader :return
    end

    def initialize(&block)
      @block = block
    end

    def runner
      Runner.new(&@block)
    end

  end
end

