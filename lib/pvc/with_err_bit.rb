class PVC
  class WithErrBit

    def initialize(&block)
      @block = block
      @stdread, @stdwrite = IO.pipe
      @errread, @errwrite = IO.pipe
    end

    def stdin
      @stdwrite
    end

    def errin
      @errwrite
    end

    def start(following_bit)
      @stdthread = Thread.new do
        @stdread.each_line do |line|
          following_bit.stdin.puts line
        end rescue nil
      end
      @errthread = Thread.new do
        @errread.each_line do |line|
          following_bit.stdin.puts line
        end rescue nil
      end
    end

    def finish
      @stdwrite.close
      @errwrite.close
      @stdread.close
      @errread.close
      @stdthread.join
      @errthread.join
    end

  end
end

