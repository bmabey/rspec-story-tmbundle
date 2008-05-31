require File.dirname(__FILE__)+'/../text_mate_helper'
require 'rubygems'
require 'spec/story/step'

module Spec
  module Mate
    module Story
      
      class StoryHelper
        def method_missing(method, args)
          yield if block_given?
        end
        
        def add_step(type, pattern)
          step = Spec::Story::Step.new(pattern){raise "Step doesn't exist."}
          @steps << {:file => @full_steps_file_path, :step => step, :type => type, 
                      :pattern => pattern, :tag => @current_step_name,
                      :line_number => caller[1].match(/:(\d+)/).captures.first.to_i}
        end
        
        def Given(pattern)
          add_step('given', pattern)
        end
        
        def When(pattern)
          add_step('when', pattern)
        end
        
        def Then(pattern)
          add_step('then', pattern)
        end
        
        
        def initialize(project_root, full_file_path)
          @project_root = project_root
          @full_file_path = full_file_path
        end
        
        def goto_alternate_file
          ::Spec::Mate::TextMateHelper.open_or_prompt(alternate_file(full_file_path))
        end
        
        def choose_steps_file
          if step_names = related_step_files
            step_file_index = TextMate::UI.menu(step_names)
            exit if step_file_index.nil?
            ::Spec::Mate::TextMateHelper.open_or_prompt(full_path_for_step_name(step_names[step_file_index]))
          end
        end
        
        def find_step(line_number)
          return unless is_story_file?
          
          current_step_type, current_step_name = get_current_step_info(line_number)
          
          if (matching_step = find_matching_step(current_step_type, current_step_name))
            next_line = @step_file_contents[matching_step[:tag]].split("\n")[matching_step[:line_number]]
            col_number = (md = next_line.match(/\s*($|[^\s])/)) ? md[0].length : 1
            ::Spec::Mate::TextMateHelper.open_or_prompt(matching_step[:file], matching_step[:line_number]+1, col_number)
          elsif goto_alternate_file
            insert_new_step_snippet(current_step_type, current_step_name)
          end
        end
        
      protected
        attr_reader :full_file_path, :project_root
        # def file_type(path)
        #   if path =~ /\.(story|txt)$/
        #     return 'story'
        #   elsif path =~ /_steps\.rb$/
        #     return 'steps'
        #   elsif path =~ /stories\/(.*)\.rb$/
        #     return 'story_runner'
        #   end
        #   'file'
        # end
        
        def insert_new_step_snippet(current_step_type, current_step_name)
          snippet_text = "foo bar blah blah"
          ::Spec::Mate::TextMateHelper.insert_text_into_current_file(snippet_text, 10, 2)
        end
        
        def get_current_step_info(line_number)
          line_index = line_number.to_i-1
          content_lines = File.open(full_file_path){|f| f.read}.split("\n")
          
          line_text = content_lines[line_index].strip
          return unless line_text.match(/^(given|when|then|and)(.*)/i)
          source_step_name = $2.strip
          
          step_type_line = content_lines[0..line_index].reverse.detect{|l| l.match(/^\s*(given|when|then)\s*(.*)$/i)}
          step_type = $1.downcase
          
          return step_type, source_step_name
        end
        
        def find_matching_step(current_step_type, current_step_name)
          # Match step
          step_names = parse_steps(File.open(story_runner_file_for(full_file_path)){|f| f.read})
          
          @steps = []
          @step_file_contents = {}
          
          step_names.each do |step_name|
            @current_step_name = step_name
            @full_steps_file_path = full_path_for_step_name(@current_step_name)
            
            @step_file_contents[@current_step_name] = File.open(@full_steps_file_path){|f| f.read}
            eval(@step_file_contents[@current_step_name])
          end
          
          # Find matching step
          @steps.detect{|s| s[:type] == current_step_type && s[:step].matches?(current_step_name) }
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
        
        
        
        
        
        
        
        def related_step_files
          if is_story_file?(full_file_path)
            story_name = full_file_path.match(/\/([^\.\/]*)\.(story|txt)$/).captures.first
            steps_file_path = File.dirname(full_file_path) + "/../#{story_name}.rb"
            
            parse_steps(File.open(steps_file_path){|f| f.read})
          else
            step_files = Dir["#{project_root}/stories/**/*_steps.rb"]
            step_files.collect{|f| f.match(/([^\/]*)_steps.rb$/).captures.first }.sort
          end
        end
        
        def story_runner_file_for(path)
          return unless is_story_file?(path)
          path.gsub(/\/stories\/([^\.\/]*)\.story$/, '/\1.rb')
        end
        
        def parse_steps(content)
          $1.gsub(':', '').split(',').collect{|s| s.strip} if content =~ /with_steps_for\s*\(?(.*)\)?\s?(do|\{)/
        end
        
        def full_path_for_step_name(step_name)
          File.expand_path(Dir["#{project_root}/**/stories/**/#{step_name}_steps.rb"].first)
        end
        
        def is_story_file?(file_path = full_file_path)
          file_path.match(/\.(story|txt)$/)
        end
        

      end
      
    end
  end
end






