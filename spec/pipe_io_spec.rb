require "childprocess"

describe "pipe io" do

  it "should run forever..." do

    # - pipe opened
    # - process forked -> f1, f2 both have copy of pipe
    # - f2 exec'd without closing its copy of pipe
    # - can always read from pipe because f2's copy never gets closed, until...
    # - f2 terminates and its copy gets cleaned up

    r, w = IO.pipe

    # r.close_on_exec = true
    # w.close_on_exec = true

    process = ChildProcess.build("cat")
    process.duplex = true
    process.io.inherit!
    process.start

    last_line = nil
    thread = Thread.new do
      r.each_line { |line| last_line = line }
    end

    w.puts "hello world"
    w.close
    print "joining thread... "

    thread.join
    puts "done"

    process.io.stdin.close
    process.wait
  end

  it "should work properly when..." do
    pending
  end

  it "should get a final unterminated line via #each line" do
    pending
  end

end

