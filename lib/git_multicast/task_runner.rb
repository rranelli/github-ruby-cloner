module GitMulticast
  class TaskRunner
    include Process

    def initialize(tasks, formatter = OutputFormatter.new(Time.now))
      @tasks = tasks
      @formatter = formatter
    end

    def run!
      tasks
        .map(&method(:future))
        .map(&:get)
        .inject('', &:+)
    end

    protected

    attr_reader :tasks, :formatter

    def future(task)
      PoorMansFuture.new { formatter.single_format(task.call) }
    end

    class PoorMansFuture
      def initialize(&block)
        @thread = Thread.new do
          Thread.current[:output] = block.call
        end
      end

      def get
        thread.join
        thread[:output]
      end

      attr_reader :thread
    end
  end
end
