require 'irt/prompter'

module IRT

  module Utils

    extend self

    # this will create a tmp file and start IRB
    # but it will be left in file mode at EOF (sort of irt-standby)
    def load_irt(run=true)
      return if IRT.initialized
      puts IRT::Utils.copyright
      ARGV.clear
      tmp_path = if run
                   create_tmp_file {|as_file| IRT::Session.run_file as_file}
                 else
                   create_tmp_file
                 end
      ARGV.push tmp_path
      IRB.start
    end

    def create_tmp_file(&block)
      require 'tempfile'
      tmp_file = Tempfile.new(['', '.irt'])
      tmp_file << "\n" # one empty line makes irb of 1.9.2 happy
      tmp_file.flush
      tmp_path = tmp_file.path
      at_exit { check_save_tmp_file(tmp_file, &block) }
      tmp_path
    end

    def save_as(as_file_local, source_path=IRT.irt_file, &block)
      as_file = File.expand_path(as_file_local)
      if File.exists?(as_file)
        return false if IRT::Prompter.no? %(Do you want to overwrite "#{as_file}"?), :hint => '[y|<enter=n]', :default => 'n'
      end
      dirname = File.dirname(as_file)
      FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
      FileUtils.cp source_path, as_file
      if block && IRT::Prompter.yes?( %(Do you want to run the file "#{as_file_local}" now?) )
        block.call as_file, source_path
      end
    end

    def version
      @version ||= File.read(File.expand_path('../../../VERSION', __FILE__)).strip
    end

    def copyright
      @copyrignt ||= Dye.dye "irt #{version} (c) 2010-2011 Domizio Demichelis", :blue, :bold
    end

  private

    def check_save_tmp_file(tmp_file, &block)
      if tmp_file.size > 1
        IRT::Prompter.yes? %(The template file has been modified, do you want to save it?) do
          IRT::Prompter.choose %(Enter the file path to save:), /[\w0-9_]/ do |as_file|
            save_as(as_file, tmp_file.path, &block)
          end
        end
      end
    end

  end
end
