module PVC
  class InputPiece

    class Runner
      def initialize(input)
        @input = input
        @read, @write = IO.pipe
        @read.close_on_exec = true
        @write.close_on_exec = true
      end

      def stdin
        @write
      end

      def start(following_piece)
        following_piece.stdin.write(@input)
        following_piece.stdin.flush
      end

      def finish
        @write.close
        @read.close
      end
    end

    def initialize(input)
      @input = input
    end

    def runner
      Runner.new(@input)
    end

  end
end

