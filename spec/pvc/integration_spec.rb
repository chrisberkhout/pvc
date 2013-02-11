require "pvc"

describe "pvc" do

  describe "(synopsis tests)" do

    it "should run a single process" do
      PVC.new("echo", "hello").run.stdout.should == "hello\n"
    end

    it "should pipe from one process to another" do
      PVC.new("echo", "hello").to(*%w{tr h H}).run.stdout.should == "Hello\n"
    end

    it "should let you get stdout" do
      PVC.new("bash", "-c", "echo hello && ls doesnotexist").run.stdout.should == "hello\n"
    end

    it "should let you get stderr" do
      PVC.new("bash", "-c", "echo hello && ls doesnotexist").run.stderr.should == "ls: doesnotexist: No such file or directory\n"
    end

    it "should let you get stdout and stderr together" do
      PVC.new("bash", "-c", "echo hello && ls doesnotexist").run.stdboth.should == "hello\nls: doesnotexist: No such file or directory\n"
    end

    it "should let you get the exit code of the last process" do
      PVC.new("echo", "hello").run.code.should == 0
      PVC.new("bash", "-c", "echo hello && ls doesnotexist").run.code.should == 1
    end

    it "should let you get several outputs from the final result" do
      PVC.new("bash", "-c", "echo hello && ls doesnotexist").run.get(:stderr, :code).should == ["ls: doesnotexist: No such file or directory\n", 1]
    end

    it "should let you input into the stdin" do
      PVC.new.input("one\ntwo\nthree\n").to("sort", "-r").run.stdout.should == "two\nthree\none\n"
    end

    it "should let you process intermediate results with Ruby" do
      PVC.new.input("one\ntwo\nthree\n").to do |i,o|
        i.each_line { |line| o.puts line if line.match(/^t/) }
      end.to("cat").run.stdout.should == "two\nthree\n"
    end

    it "should let you mix stderr and stdin at some point in a pipeline" do
      PVC.new("bash", "-c", "echo hello && ls doesnotexist").with_err.to("wc", "-l").run.stdout.should == "       2\n"
    end

    it "should let you pass on only stderr at some point in a pipeline" do
      PVC.new("bash", "-c", "echo hello && ls doesnotexist").only_err.to("wc", "-l").run.stdout.should == "       1\n"
    end

    it "should let you insert one pipeline into another" do
      upcase_unique_pipeline = PVC.new("tr", "a-z", "A-Z").to("uniq")
      string = "hello\nHeLlO\nworld\nWoRlD\n"
      PVC.new.input(string).to(upcase_unique_pipeline).to("sort", "-r").run.stdout.should == "WORLD\nHELLO\n"
    end

  end

  describe "(original manual tests)" do

    let(:log) { [] }

    it "should work with 2 shell commands and a block" do
      PVC.new.
        to("bash", "-c", "echo BBB && echo AAA").
        to("sort").
        to do |input, output|
          input.each_line { |line| log << line.chomp }
        end.run

      log.should == %w{AAA BBB}
    end

    it "should work with sevearal blocks" do
      PVC.new.
        to("bash", "-c", "echo BBB && echo AAA").
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
        to("bash", "-c", "echo BBB && echo AAA").
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

