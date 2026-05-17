# frozen_string_literal: true

require "ruby-limiter"

module RateLimitedJira
  class Client
    class InProcessBased < Client
      def rate_limit(&block)
        rate_queue.shift

        block.call
      end

      def rate_queue
        @rate_queue ||=
          Limiter::RateQueue.new(rate_limit_per_interval, interval: rate_interval_in_seconds)
      end
    end
  end
end
