module Spec
  module Mate
    class TextMateHelper
      
      class << self
        def open_or_prompt(file_path)
          new.open_or_prompt(file_path)
        end
      end
      
      def open_or_prompt(file_path)
        
      end  
    
    protected
      def tm_open(file, options = {})
        line = options[:line]
        wait = options[:wait]
        if line.nil? && /^(.+):(\d+)$/.match(file)
          file = $1
          line = $2
        end

        unless /^\//.match(file)
          file = File.join((ENV['TM_PROJECT_DIRECTORY'] || Dir.pwd), file)
        end

        args = []
        args << "-w" if wait
        args << e_sh(file)
        args << "-l #{line}" if line
        %x{"#{ENV['TM_SUPPORT_PATH']}/bin/mate" #{args * " "}}
      end
    end
  end
end