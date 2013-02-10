module PVC
  class WithErrPiece

    def initialize(&block)
      @block = block
      @stdread, @stdwrite = IO.pipe
      @errread, @errwrite = IO.pipe
      @stdread.close_on_exec = true
      @stdread.close_on_exec = true
      @errwrite.close_on_exec = true
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
end

