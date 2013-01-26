require "childprocess"

# Example usage:
# 
#   PVC.new.
#     to("ls").
#     to("sort").
#     to do |input, output|
#       input.each_line do |line|
#         output.puts line
#         puts "FIRST BLOCK SAW... #{line}"
#       end rescue nil
#     end.
#     to("sort", "-r").
#     to do |input, output|
#       input.each_line do |line|
#         output.puts line
#         puts "SECOND BLOCK SAW... #{line}"
#       end rescue nil
#     end.run
# 

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

  def initialize
    @bits = []
  end

  def to(*args, &block)
    if block_given?
      @bits << BlockBit.new(&block)
    else
      @bits << ProcessBit.new(*args)
    end
    self
  end

  def with_err
    @bits << WithErrBit.new
    self
  end

  def run
    @bits = [NullBit.new] + @bits + [NullBit.new]
    
    @bits[1..-2].zip(@bits[2..-1]).reverse.each do |current, following|
      current.start(following)
    end

    @bits.each do |current|
      current.finish
    end

  end

end

