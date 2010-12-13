module IRT
  module Directives
    module History

      def history(lines=IRT.history.tail_size)
        IRT.history.print_tail lines
      end
      alias :h :history

      def h0
        history 0
      end
      alias :hh :h0

      def history_remove_last
        IRT.history.remove_last_line
      end
      alias :hrl :history_remove_last

      def history_clear
        IRT.history.clear_lines
      end

      def add_desc(description)
        IRT.history.insert_desc_line %(desc "#{description}")
      end
      alias :ad :add_desc

      def add_test(description=nil)
        context = IRB.CurrentContext
        last_value = context.last_value
        add_desc(description) if description
        begin
          evaled = context.workspace.evaluate(self, last_value.inspect)
        rescue Exception
        end
        # the eval of the last_value.inspect == the last_value
        test_str = if evaled == context.last_value
                     # same as last_value_eql? but easier to read for multiline strings without escaping chars
                     if last_value.is_a?(String) && last_value.match(/\n$/) && !last_value.match(/\e/)
                       "last_string_eql? <<EOS\n#{last_value}EOS"
                     else
                       "last_value_eql?( #{last_value.inspect} )"
                     end
                   else # need YAML
                     "last_yaml_eql? %(#{IRT.yaml_dump(last_value)})"
                   end
        IRT.history.add_session_line test_str
        IRT.history.lines << IRT::History::EmptyLine.new  # add an empty line for readability
      end
      alias :at :add_test

      def add_comment(comment)
        IRT.history.add_session_line "# #{comment}"
      end
      alias :ac :add_comment

      def add_empty_line
        IRT.history.add_empty_line
      end
      alias :ael :add_empty_line

    end
  end
end
