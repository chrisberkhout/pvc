class PVC
  class ProcessBit

    def initialize(*args)
      @args = args
      @process = ChildProcess.build(*args)
    end

    def stdin
      @process.io.stdin
    end

    def start(following_bit)
      @process.duplex = true
      @process.io.stdout = following_bit.stdin
      @process.io.stderr = following_bit.errin if following_bit.respond_to?(:errin)
      @process.start
    end

    def finish
      @process.io.stdin.close
      @process.wait
    end

  end
end

