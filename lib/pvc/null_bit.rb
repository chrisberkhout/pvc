class PVC
  class NullBit
    
    def initialize
      @read, @write = IO.pipe
    end

    def stdin
      @write
    end

    def finish
      @write.close
    end

  end
end

