require "childprocess"

describe "pipe io" do

  def fork_childprocess
    ChildProcess.unix?.should == true && ChildProcess.posix_spawn?.should == false  # to ensure this does fork+exec
    process = ChildProcess.build("cat")
    process.duplex = true  # to make stdin available on start
    process.start
    yield if block_given?
    process.io.stdin.close
    process.wait
  end

  it "will not show EOF on close if a fork has an open copy of the file handle" do
    read, write = IO.pipe
    fork_childprocess do
      write.close
      lambda { read.read_nonblock(1) }.should raise_error(Errno::EAGAIN)  # not yet EOF
    end
  end

  it "should show EOF on close if the fork has closed its copy of the file handle (by exiting)" do
    read, write = IO.pipe
    fork_childprocess
    write.close
    lambda { read.read_nonblock(1) }.should raise_error(EOFError)
  end

  it "should show EOF on close if the fork has closed its copy of the file handle (by closing on exec)" do
    read, write = IO.pipe
    write.close_on_exec = true
    fork_childprocess do
      write.close
      lambda { read.read_nonblock(1) }.should raise_error(EOFError)
    end
  end

  it "should not close everywhere if closed in a fork" do
    read, write = IO.pipe
    read.close_on_exec = true
    write.close_on_exec = true
    fork_childprocess do
      read.closed?.should be_false
    end
  end

  it "should get a final unterminated line via #each_line" do
    read, write = IO.pipe
    lines_read = []
    thread = Thread.new do
      read.each_line { |line| lines_read << line }
    end
    write.puts "terminated line"
    write.print "unterminated line"
    write.close
    thread.join
    lines_read.should == ["terminated line\n", "unterminated line"]
  end

end

