module PVC
  class BlockBit

    def initialize(&block)
      @block = block
      @read, @write = IO.pipe
      @read.close_on_exec = true
      @write.close_on_exec = true
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
      @thread.join
    end

  end
end

