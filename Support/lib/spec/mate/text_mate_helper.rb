require "#{ENV['TM_SUPPORT_PATH']}/lib/textmate"
require "#{ENV['TM_SUPPORT_PATH']}/lib/ui"
require "#{ENV['TM_SUPPORT_PATH']}/lib/exit_codes"

module Spec
  module Mate
    class TextMateHelper
      
      class << self
        def open_or_prompt(file_path, line_number = 1, col_number = 1)
          new.open_or_prompt(file_path, line_number, col_number)
        end
        
        def insert_text_into_current_file(text)
          new.insert_text_into_current_file(text)
        end
      end
      
      def insert_text_into_current_file(text)
        insert_text_into_textmate(text)
      end
      
      def open_or_prompt(file_path, line_number = 1, col_number = 1)
        if File.file?(file_path)
          TextMate.go_to(:file => file_path, :line => line_number, :column => col_number)
          return true
        elsif TextMate::UI.request_confirmation(:title => "Create new file?", :prompt => "Do you want to create\n#{file_path.gsub(/^(.*?)stories/, 'stories')}?")
          write_and_open(file_path)
          return true
        end
        false
      end  
    
    protected
      def write_and_open(file_path)
        content = case file_path
                  when /(story|txt)$/ then story_content(file_path)
                  when /_steps\.rb$/  then steps_content(file_path)
                  else ''
                  end
        
        `mkdir -p "#{File.dirname(file_path)}"`
        `touch "#{file_path}"`
        `osascript &>/dev/null -e 'tell app "SystemUIServer" to activate' -e 'tell app "TextMate" to activate'`
        `"$TM_SUPPORT_PATH/bin/mate" "#{file_path}"`
        
        insert_text_into_textmate(content)
      end
      
      def insert_text_into_textmate(text)
        `osascript &>/dev/null -e 'tell app "SystemUIServer" to activate' -e 'tell app "TextMate" to activate'`
        escaped_content = text.gsub("\n","\\n").gsub('$','\\$').gsub('"','\\\\\\\\\\\\"')
        `osascript &>/dev/null -e "tell app \\"TextMate\\" to insert \\"#{escaped_content}\\" as snippet true"`
      end
      
      def story_content(file_path)
        snippet('Story.tmSnippet')
      end
      
      def steps_content(file_path)
        step_name = file_path.match(/([^\/]*)_steps.rb$/).captures.first
        content = <<-STEPS
steps_for(:${1:#{step_name}}) do
  Given "${2:condition}" do
    $0
  end
end
STEPS
      end
      
      # Extracts the snippet text
      def snippet(snippet_name)
        snippet_file = File.expand_path(File.dirname(__FILE__) + "/../../../../Snippets/#{snippet_name}")
        xml = File.open(snippet_file).read
        xml.match(/<key>content<\/key>\s*<string>([^<]*)<\/string>/m)[1]
      end
      
    end
  end
end