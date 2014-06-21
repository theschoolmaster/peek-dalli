require 'atomic'

module Peek
  module Views
    class Dalli < View
      def initialize(options = {})
        @duration = Atomic.new(0)
        @calls = Atomic.new(0)

        @reads = Atomic.new(0)
        @misses = Atomic.new(0)
        @writes = Atomic.new(0)

        @keys = []

        setup_subscribers
      end

      def formatted_duration
        ms = @duration.value * 1000
        if ms >= 1000
          "%.2fms" % ms
        else
          "%.0fms" % ms
        end
      end

      def cache_keys
        @keys.uniq
      end

      def results
        {
          :duration => formatted_duration,
          :calls => @calls.value,
          :reads => @reads.value,
          :misses => @misses.value,
          :writes => @writes.value,
          :keys => @keys.uniq.join(',')
        }
      end

      private

      def setup_subscribers
        # Reset each counter when a new request starts
        before_request do
          @duration.value = 0
          @calls.value = 0

          @reads.value = 0
          @misses.value = 0
          @writes.value = 0

          @keys = []
        end

        subscribe('cache_read.active_support') do |name, start, finish, id, payload|
          if payload[:hit].blank?
            @misses.update { |value| value + 1 }
          else
            @reads.update { |value| value + 1 }
            @keys << payload[:key]
          end
        end

        subscribe('cache_write.active_support') do
          @writes.update { |value| value + 1 }
        end

        subscribe(/cache_(.*).active_support/) do |name, start, finish, id, payload|
          duration = (finish - start)
          @duration.update { |value| value + duration }
          @calls.update { |value| value + 1 }
        end
      end
    end
  end
end
