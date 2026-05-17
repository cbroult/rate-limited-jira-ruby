# frozen_string_literal: true

RSpec.describe RateLimitedJira::Client do
  describe ".build" do
    let(:jira_options) { {} }

    context "when implementation is unspecified" do
      subject(:result) { described_class.build(jira_options) }

      it { expect(result).to be_a(RateLimitedJira::Client::InProcessBased) }
    end

    context "when implementation is :in_process" do
      subject(:result) { described_class.build(jira_options, implementation: :in_process) }

      it { expect(result).to be_a(RateLimitedJira::Client::InProcessBased) }
    end

    context "when implementation is blank" do
      subject(:result) { described_class.build(jira_options, implementation: "") }

      it { expect(result).to be_a(RateLimitedJira::Client::InProcessBased) }
    end

    context "when implementation is :redis" do
      subject(:result) { described_class.build(jira_options, implementation: :redis) }

      it { expect(result).to be_a(RateLimitedJira::Client::RedisBased) }
    end

    context "when implementation is unknown" do
      subject(:result) { described_class.build(jira_options, implementation: :unknown) }

      it do
        expect { result }
          .to raise_error(ArgumentError, /:unknown.*unknown rate limiting implementation/)
      end
    end
  end

  RSpec.shared_examples "a rate limited client" do
    before do
      allow(client).to receive_messages(original_request: :response)
    end

    it "returns the response" do
      expect(client.request(:get, "/path/to/resource")).to eq(:response)
    end

    it "calls the original request method" do
      client.request(:get, "/path/to/resource")

      expect(client).to have_received(:original_request).with(:get, "/path/to/resource")
    end
  end

  describe "#request" do
    let(:client) { described_class.new({}, rate_interval_in_seconds:, rate_limit_per_interval:) }

    context "when rate limiting is disabled" do
      let(:rate_interval_in_seconds) { 0 }
      let(:rate_limit_per_interval) { 0 }

      it_behaves_like "a rate limited client"

      it "does not use the rate limiter" do
        allow(client).to receive(:original_request).with(:get, "/path/to/resource")
        expect(client).not_to receive(:rate_limit)

        client.request(:get, "/path/to/resource")
      end
    end

    context "when rate limiting is enabled" do
      let(:rate_interval_in_seconds) { 2 }
      let(:rate_limit_per_interval) { 1 }

      it_behaves_like "a rate limited client" do
        before { allow(client).to receive(:rate_limit).and_yield }
      end

      it "uses the rate limiter" do
        allow(client).to receive(:original_request).with(:get, "/path/to/resource")
        expect(client).to receive(:rate_limit).and_yield

        client.request(:get, "/path/to/resource")
      end
    end
  end
end
