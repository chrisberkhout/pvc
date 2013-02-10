module PVC
  class ResultPiece
    
    def initialize
      @stdread, @stdwrite = IO.pipe
      @errread, @errwrite = IO.pipe
      @stdread.close_on_exec = true
      @stdwrite.close_on_exec = true
      @errread.close_on_exec = true
      @errwrite.close_on_exec = true
      @stdout = []
      @stderr = []
      @stdboth = []
    end

    def stdin
      @stdwrite
    end

    def errin
      @errwrite
    end

    def start(following=nil)
      @stdthread = Thread.new do
        @stdread.each_line do |line|
          @stdout << line
          @stdboth << line
        end
      end
      @errthread = Thread.new do
        @errread.each_line do |line|
          @stderr << line
          @stdboth << line
        end
      end
    end

    def finish
      @stdwrite.close
      @errwrite.close
      @stdthread.join
      @errthread.join
    end

    def stdout
      @stdout.join("")
    end

    def stderr
      @stdout.join("")
    end

    def stdboth
      @stdout.join("")
    end

  end
end

