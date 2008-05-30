dir = File.dirname(__FILE__)
$LOAD_PATH.unshift "#{dir}/../../../rspec/lib" 
module Spec::Example::ExampleMethods
  def set_env
    root = File.expand_path(File.dirname(__FILE__) + '/../../../example_rails_app/vendor/plugins/rspec')
    ENV['TM_SPEC'] = "ruby -I\"#{root}/lib\" \"#{root}/bin/spec\""
    ENV['TM_RSPEC_HOME'] = "#{root}"
    ENV['TM_PROJECT_DIRECTORY'] = File.expand_path(File.dirname(__FILE__))
    ENV['TM_FILEPATH'] = nil
    ENV['TM_LINE_NUMBER'] = nil
  end
end
require 'stringio'
#require File.dirname(__FILE__) + '/../lib/spec/mate'