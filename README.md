# PVC

Pipe between processes as easily as in the shell

## Check it out

    # run the specs
    bundle exec rspec spec

## Install it as a RubyGem

This code is packaged as a Gem. If you like, you can build and install it by running:

    gem build pvc.gemspec
    gem install pvc-*.gem

## Synopsis - implemented

    # Run a single process
    PVC.new("echo hello").run

    # Or pipe from one process to another
    PVC.new("echo hello").to("tr h H").run

    # Get individual or several outputs from the final result
    PVC.new("echo hello && ls doesnotexist").run.stdout   # => "hello\n"
    PVC.new("echo hello && ls doesnotexist").run.stderr   # => "ls: doesnotexist: No such file or directory\n"
    PVC.new("echo hello && ls doesnotexist").run.stdboth  # => "hello\nls: doesnotexist: No such file or directory\n"
    PVC.new("echo hello && ls doesnotexist").run.code     # => 1
    stderr, code = PVC.new("echo hello && ls doesnotexist").run.get(:stderr, :code)  # => ["ls: doesnotexist: No such file or directory\n", 1]

## Synopsis - unimplemented

    # Feed into stdin
    PVC.new.push("one\ntwo\nthree\n").to("sort -r").run.stdout  # => "two\nthree\none\n"

    # Process intermediate results with Ruby
    PVC.new("cat some.log").to { |in,out| in.each_line { |line| out.puts line if line.match(/ERROR/) } }.to("tail -n10").run

    # Mix stderr and stdin at some point in a pipeline
    PVC.new("echo hello && ls doesnotexist").with_err.to("wc -l").run.stdout  # => "       2\n"

    # Pass on only stderr at some point in a pipeline
    PVC.new("echo hello && ls doesnotexist").only_err.to("wc -l").run.stdout  # => "       1\n"

    # Insert one pipeline into another
    upcase_unique_pipeline = PVC.new("tr a-z A-Z").to("uniq")
    PVC.new.push("hello\nHeLlO\nworld\nWoRlD\n").to(upcase_unique_pipeline).to("sort -r").run.stdout # => "WORLD\nHELLO"

    # Kill run if it does not finish in time (miliseconds)
    PVC.new("sleep 2").run(:timeout => 1000)

    # Get all returns across a whole pipeline
    PVC.new("ls doesnotexist").to { |io| return Foo.new }.to("true").run.returns  # => ["1\n", #<Foo:0x007fd47917a7f0>, "0\n"]

## Compatibility

Written and tested with Ruby 1.9.3.

## Contact

[Chris Berkhout](http://chrisberkhout.com/about)

