# PVC

Pipe between processes as easily as in the shell (currently only on platforms with `IO.pipe`).

## Install it

    gem install pvc

## Check out the code

    git clone git://github.com/chrisberkhout/pvc.git && pvc
    bundle install
    bundle exec rspec spec

## Build the RubyGem yourself

If you like, you can build and install it by running:

    gem build pvc.gemspec
    gem install pvc-*.gem

## Synopsis - implemented

    # Run a single process
    PVC.new("echo", "hello").run

    # Or pipe from one process to another
    PVC.new("echo", "hello").to(*%w{tr h H}).run

    # Get individual or several outputs from the final result
    PVC.new("bash", "-c", "echo hello && ls doesnotexist").run.stdout   # => "hello\n"
    PVC.new("bash", "-c", "echo hello && ls doesnotexist").run.stderr   # => "ls: doesnotexist: No such file or directory\n"
    PVC.new("bash", "-c", "echo hello && ls doesnotexist").run.stdboth  # => "hello\nls: doesnotexist: No such file or directory\n"
    PVC.new("bash", "-c", "echo hello && ls doesnotexist").run.code     # => 1
    stderr, code = PVC.new("bash", "-c", "echo hello && ls doesnotexist").run.get(:stderr, :code)  # => ["ls: doesnotexist: No such file or directory\n", 1]

    # Input a string into stdin
    PVC.new.input("one\ntwo\nthree\n").to("sort", "-r").run.stdout  # => "two\nthree\none\n"

    # Process intermediate results with Ruby
    PVC.new("cat", "some.log").to { |i,o| i.each_line { |line| o.puts line if line.match(/ERROR/) } }.to("tail", "-n10").run

    # Mix stderr and stdin at some point in a pipeline
    PVC.new("bash", "-c", "echo hello && ls doesnotexist").with_err.to("wc", "-l").run.stdout  # => "       2\n"

    # Pass on only stderr at some point in a pipeline
    PVC.new("bash", "-c", "echo hello && ls doesnotexist").only_err.to("wc", "-l").run.stdout  # => "       1\n"

    # Insert one pipeline into another
    upcase_unique_pipeline = PVC.new("tr", "a-z", "A-Z").to("uniq")
    PVC.new.input("hello\nHeLlO\nworld\nWoRlD\n").to(upcase_unique_pipeline).to("sort", "-r").run.stdout # => "WORLD\nHELLO"

    # Shorthand for linewise rewriting
    PVC.new.input("hello\nworld").lines_map { |l| l.upcase }.run.stdout "HELLO\nWORLD"

    # Shorthand for linewise processing (without modifying the stream)
    count = 0
    result = PVC.new.input("hello\nworld").lines_tap { |l| count += 1 }.run
    count  # => 2
    result.stdout  # => "hello\nworld"

## Synopsis - unimplemented

    # Kill run if it does not finish in time (miliseconds)
    PVC.new("sleep", "2").run(:timeout => 1000)

## Compatibility

Written and tested with Ruby 1.9.3.

## Copyright

The MIT License

Copyright (C) 2013 by Chris Berkhout (http://chrisberkhout.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

## Contact

[Chris Berkhout](http://chrisberkhout.com/about)

