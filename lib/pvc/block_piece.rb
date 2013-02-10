module PVC
  class BlockPiece

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
      @thread = Thread.new do
        @block.call(@read, following_piece.stdin)
      end
    end

    def finish
      @write.close
      @thread.join
    end

  end
end

