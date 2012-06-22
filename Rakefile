require 'rake'


task :glean do
  require File.join(File.dirname(__FILE__), 'lib', 'glean')
  Glean.new.print_report
end

task :default => :glean