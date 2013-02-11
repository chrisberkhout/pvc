module PVC
  class Result

    attr_reader :stdout
    attr_reader :stderr
    attr_reader :stdboth

    def initialize(args)
      @stdout = args[:stdout]
      @stderr = args[:stderr]
      @stdboth = args[:stdboth]
      @returns = args[:returns]
      @codes = args[:codes]
    end

    def return
      @returns.last
    end

    def code
      @codes.last
    end

    def get(*requested_outputs)
      allowed_outputs = [:stdout, :stderr, :stdboth, :return, :code]
      raise "No such output to get!" unless (requested_outputs-allowed_outputs)==[]
      requested_outputs.map { |output_kind| self.send(output_kind) }
    end

  end
end

