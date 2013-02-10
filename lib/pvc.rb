require "childprocess"

require "pvc/pipeline"

module PVC

  def self.new(*args)
    Pipeline.new(*args)
  end

end

