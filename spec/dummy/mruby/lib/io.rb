class << self
  attr_accessor :stdout_buffer
end

SCRIPT__TOP = self
SCRIPT__TOP.stdout_buffer = ""

STDOUT = Object.new
STDOUT.define_singleton_method :write do |bytes|
  SCRIPT__TOP.stdout_buffer << bytes.to_s
end

module Kernel
  def puts(*args)
    unless args.empty?
      args.each do |arg|
        STDOUT.write arg.to_s
        STDOUT.write "\n"
      end
    else
      STDOUT.write "\n"
    end
  end
end