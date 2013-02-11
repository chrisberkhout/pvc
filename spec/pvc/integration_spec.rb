require "pvc"

describe "pvc" do

  describe "(synopsis tests)" do

    it "should run a single process" do
      PVC.new("echo hello").run.stdout.should == "hello\n"
    end

    it "should pipe from one process to another" do
      PVC.new("echo hello").to("tr h H").run.stdout.should == "Hello\n"
    end

    it "should let you get stdout" do
      PVC.new("echo hello && ls doesnotexist").run.stdout.should == "hello\n"
    end

    it "should let you get stderr" do
      PVC.new("echo hello && ls doesnotexist").run.stderr.should == "ls: doesnotexist: No such file or directory\n"
    end

    it "should let you get stdout and stderr together" do
      PVC.new("echo hello && ls doesnotexist").run.stdboth.should == "hello\nls: doesnotexist: No such file or directory\n"
    end

    it "should let you get the exit code of the last process" do
      PVC.new("echo hello").run.code.should == 0
      PVC.new("echo hello && ls doesnotexist").run.code.should == 1
    end

    it "should let you get several outputs from the final result" do
      PVC.new("echo hello && ls doesnotexist").run.get(:stderr, :code).should == ["ls: doesnotexist: No such file or directory\n", 1]
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

