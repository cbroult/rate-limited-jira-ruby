# frozen_string_literal: true

RSpec.describe RateLimitedJira::Client::RedisBased do
  describe "#rate_limit" do
    let(:client) { described_class.new({}, rate_interval_in_seconds:, rate_limit_per_interval:) }

    let(:rate_interval_in_seconds) { 2 }
    let(:rate_limit_per_interval) { 1 }
    let(:rate_limiter) { instance_double(Ratelimit) }

    let(:rate_limit_4_calls_to_original_request_code) do
      4.times { client.rate_limit { client.original_request(:get, "/path/to/resource") } }
    end

    before do
      allow(described_class).to receive_messages(rate_limiter: rate_limiter)
      allow(client).to receive(:original_request)
    end

    it "uses :exec_within_threshold to control rate limiting" do
      allow(rate_limiter).to receive(:exec_within_threshold)

      rate_limit_4_calls_to_original_request_code

      expect(rate_limiter)
        .to have_received(:exec_within_threshold)
        .with(RateLimitedJira::Client::RedisBased::RATE_LIMITER_KEY,
              { interval: rate_interval_in_seconds, threshold: rate_limit_per_interval })
        .exactly(4).times
    end

    it "keeps track of rate limiter key calls" do
      allow(rate_limiter).to receive(:exec_within_threshold).and_yield
      allow(rate_limiter).to receive(:add)

      rate_limit_4_calls_to_original_request_code

      expect(rate_limiter)
        .to have_received(:add)
        .with(RateLimitedJira::Client::RedisBased::RATE_LIMITER_KEY)
        .exactly(4).times
    end
  end
end
