require "childprocess"

require "pvc/block_bit"
require "pvc/null_bit"
require "pvc/process_bit"
require "pvc/with_err_bit"

class PVC

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
    padded_bits = [NullBit.new] + @bits + [NullBit.new]
    
    # @bits[1..-2].zip(@bits[2..-1]).reverse.each do |current, following|
    #   current.start(following)
    # end
    padded_bits.zip(padded_bits[1..-1]).reverse.each do |current, following|
      current.start(following)
    end

    padded_bits.each do |current|
      current.finish
    end

  end

end

