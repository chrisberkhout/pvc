require "childprocess"

require "pvc/pipeline"

module PVC

  def self.new(*args, &block)
    Pipeline.new(*args, &block)
  end

end

