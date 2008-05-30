require File.dirname(__FILE__)+'/../text_mate_helper'

module Spec
  module Mate
    module Story
      
      class StoryHelper
        def goto_alternate_file(file_path)
          ::Spec::Mate::TextMateHelper.open_or_prompt(alternate_file(file_path))
        end
        
        
        # def switch_to_file(path)
        #   if File.file?(path)
        #     tm_open(path)
        #   else
        #     relative = path[project_directory.length+1..-1]
        #     file_type = file_type(other)
        #     if create?(relative, file_type)
        #       content = content_for(file_type, relative)
        #       write_and_open(other, content)
        #     end
        #   end
        # end
    
        # def goto_current_step
        #   puts "NEED TO DO"
        #   return
        #   
        #   source = ENV['TM_FILEPATH']
        #   line = ENV['TM_LINE_NUMBER']
        #   
        #   puts line
        # end
        
      protected
        def file_type(path)
          if path =~ /\.(story|txt)$/
            return 'story'
          elsif path =~ /_steps\.rb$/
            return 'steps'
          elsif path =~ /stories\/(.*)\.rb$/
            return 'story_runner'
          end
          'file'
        end
    
        def alternate_file(path)
          if path =~ /^(.*)\/(steps|stories)\/(.*?)$/
            prefix, parent, rest = $1, $2, $3
            
            case parent
            when 'steps' then
              path = path.gsub(/\/steps\//, '/stories/')
              path = path.gsub(/_steps\.rb$/, '.story')
            when 'stories' then
              path = path.gsub(/\/stories\/([^\/]*)\.(story|txt)$/, '/steps/\1_steps.rb')
            end
            return path
          end
        end
        

      end
      
    end
  end
end