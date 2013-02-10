module PVC
  class BlockBit

    def initialize(&block)
      @block = block
      @read, @write = IO.pipe
    end

    def stdin
      @write
    end

    def start(following_bit)
      @thread = Thread.new do
        @block.call(@read, following_bit.stdin)
      end
    end

    def finish
      @write.close
      @read.close
      @thread.join
    end

  end
end

