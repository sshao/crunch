require 'zeus/rails'

class Thread
  class Backtrace
    class Location
      alias_method :path, :absolute_path
    end
  end
end

class CustomPlan < Zeus::Rails

  # def my_custom_command
  #  # see https://github.com/burke/zeus/blob/master/docs/ruby/modifying.md
  # end

end

Zeus.plan = CustomPlan.new
