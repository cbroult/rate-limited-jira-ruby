# frozen_string_literal: true

require "jira-ruby"

module RateLimitedJira
  class Client < JIRA::Client
    NO_RATE_LIMIT_PER_INTERVAL = 0
    NO_RATE_INTERVAL_IN_SECONDS = 0

    def self.build(jira_options, rate_limit_per_interval: 0, rate_interval_in_seconds: 0, implementation: :in_process)
      implementation_class_for(implementation)
        .new(jira_options,
             rate_limit_per_interval: rate_limit_per_interval,
             rate_interval_in_seconds: rate_interval_in_seconds)
    end

    def self.implementation_class_for(implementation)
      impl = implementation.to_s.then { |s| s.empty? ? :in_process : s.to_sym }
      case impl
      when :in_process then InProcessBased
      when :redis      then RedisBased
      else
        raise ArgumentError, "#{implementation.inspect}: unknown rate limiting implementation. " \
                             "Valid options: :in_process, :redis"
      end
    end
    private_class_method :implementation_class_for

    attr_reader :rate_interval_in_seconds, :rate_limit_per_interval

    def initialize(options, rate_interval_in_seconds: 0, rate_limit_per_interval: 0)
      super(options)
      @rate_interval_in_seconds = rate_interval_in_seconds
      @rate_limit_per_interval = rate_limit_per_interval
    end

    alias original_request request

    def request(*)
      if rate_limit_per_interval == NO_RATE_LIMIT_PER_INTERVAL
        original_request(*)
      else
        rate_limit { original_request(*) }
      end
    end

    def rate_limit(&)
      raise NotImplementedError, "rate_limit must be implemented by a subclass"
    end
  end
end

require_relative "client/in_process_based"
require_relative "client/redis_based"
