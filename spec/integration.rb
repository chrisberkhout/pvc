require "pvc"

describe "pvc" do

  let(:log) { [] }

  it "should work with 2 shell commands and a block" do
    PVC.new.
      to("echo BBB && echo AAA").
      to("sort").
      to do |input, output|
        input.each_line do |line|
          log << line.chomp
        end rescue nil
      end.run

    log.should == %w{AAA BBB}
  end

  it "should work with sevearal blocks" do
    PVC.new.
      to("echo BBB && echo AAA").
      to("sort").
      to do |input, output|
        input.each_line do |line|
          output.write line
        end rescue nil
      end.
      to do |input, output|
        input.each_line do |line|
          log << line.chomp
        end rescue nil
      end.run

    log.should == %w{AAA BBB}
  end

  it "should work with sevearal blocks separated by a shell command" do
    PVC.new.
      to("echo BBB && echo AAA").
      to("sort").
      to do |input, output|
        input.each_line do |line|
          output.write line
        end rescue nil
      end.
      to("cat").
      to do |input, output|
        input.each_line do |line|
          log << line.chomp
        end rescue nil
      end.run

    log.should == %w{AAA BBB}
  end

end

