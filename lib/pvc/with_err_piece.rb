module PVC
  class WithErrPiece

    class Runner
      def initialize
        @stdread, @stdwrite = IO.pipe
        @errread, @errwrite = IO.pipe
        @stdread.close_on_exec = true
        @stdwrite.close_on_exec = true
        @errread.close_on_exec = true
        @errwrite.close_on_exec = true
      end

      def stdin
        @stdwrite
      end

      def errin
        @errwrite
      end

      def start(following_piece)
        @stdthread = Thread.new do
          @stdread.each_line { |line| following_piece.stdin.puts line }
        end
        @errthread = Thread.new do
          @errread.each_line { |line| following_piece.stdin.puts line }
        end
      end

      def finish
        @stdwrite.close
        @errwrite.close
        @stdthread.join
        @errthread.join
      end
    end

    def runner
      Runner.new
    end

  end
end

