require "childprocess"

require "pvc/block_piece"
require "pvc/null_piece"
require "pvc/process_piece"
require "pvc/with_err_piece"
require "pvc/result_piece"
require "pvc/result"

module PVC
  class Pipeline

    def initialize(*args, &block)
      @pieces = []
      if args.length > 0 || block_given?
        self.to(*args, &block)
      end
    end

    def to(*args, &block)
      if block_given?
        @pieces << BlockPiece.new(&block)
      else
        @pieces << ProcessPiece.new(*args)
      end
      self
    end

    def with_err
      @pieces << WithErrPiece.new
      self
    end

    def run
      runners = ([NullPiece.new] + @pieces + [ResultPiece.new]).map(&:runner)
      
      runners.zip(runners[1..-1]).reverse.each do |current, following|
        current.start(following)
      end

      runners.each do |current|
        current.finish
      end

      Result.new(
        :stdout => runners.last.stdout,
        :stderr => runners.last.stderr,
        :stdboth => runners.last.stdboth,
        :codes => runners.inject([]) { |codes, runner| codes << runner.code if runner.respond_to?(:code); codes },
        :returns => runners.inject([]) { |returns, runner| returns << runner.return if runner.respond_to?(:return); returns }
      )
    end

  end
end
