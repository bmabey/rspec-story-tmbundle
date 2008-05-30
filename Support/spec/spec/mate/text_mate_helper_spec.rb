require File.dirname(__FILE__) + '/../../../lib/spec/mate/text_mate_helper'

module Spec
  module Mate
  
    describe TextMateHelper do
      before(:each) do
        ENV['TM_PROJECT_DIRECTORY'] = File.join((File.dirname(__FILE__) + '../../../fixtures')
        ENV['TM_SUPPORT_PATH'] = '/Applications/TextMate.app/Contents/SharedSupport/Support'
      end
      
      describe ".open_or_prompt" do
        it "should open the file if the file exists" do
          #TextMateHelper.
        end
        
        describe "when the file does not exist" do
          it "should prompt if the file should be created" do
            
          end
        end
      end
    end

  end
end