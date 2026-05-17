# frozen_string_literal: true

require "ratelimit"
require "redis"

module RateLimitedJira
  class Client
    class RedisBased < Client
      RATE_LIMITER_KEY = "rate_limited_jira_api_requests"

      def rate_limit(&block)
        rate_limiter.exec_within_threshold(RATE_LIMITER_KEY,
                                           interval: rate_interval_in_seconds,
                                           threshold: rate_limit_per_interval) do
          response = block.call

          rate_limiter.add(RATE_LIMITER_KEY)

          response
        end
      end

      def rate_limiter
        self.class.rate_limiter(RATE_LIMITER_KEY, rate_interval_in_seconds)
      end

      def self.rate_limiter(rate_limiter_key, rate_interval)
        @rate_limiter ||= Ratelimit.new(rate_limiter_key, bucket_interval: rate_interval)
      end
    end
  end
end
