require "pvc"

describe "pvc" do

  describe "(synopsis tests)" do

    it "should run a single process" do
      PVC.new("echo hello").run.class.should == PVC::Result
    end

    it "should pipe from one process to another" do
      PVC.new("echo hello").to("tr h H").run.class.should == PVC::Result
    end

  end

  describe "(original manual tests)" do

    let(:log) { [] }

    it "should work with 2 shell commands and a block" do
      PVC.new.
        to("echo BBB && echo AAA").
        to("sort").
        to do |input, output|
          input.each_line { |line| log << line.chomp }
        end.run

      log.should == %w{AAA BBB}
    end

    it "should work with sevearal blocks" do
      PVC.new.
        to("echo BBB && echo AAA").
        to("sort").
        to do |input, output|
          input.each_line { |line| output.write line }
        end.
        to do |input, output|
          input.each_line { |line| log << line.chomp }
        end.run

      log.should == %w{AAA BBB}
    end

    it "should work with sevearal blocks separated by a shell command" do
      PVC.new.
        to("echo BBB && echo AAA").
        to("sort").
        to do |input, output|
          input.each_line { |line| output.write line }
        end.
        to("cat").
        to do |input, output|
          input.each_line { |line| log << line.chomp }
        end.run

      log.should == %w{AAA BBB}
    end

  end

end

