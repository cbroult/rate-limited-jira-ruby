# frozen_string_literal: true

require_relative "lib/rate_limited_jira/version"

Gem::Specification.new do |spec|
  spec.name = "rate-limited-jira-ruby"
  spec.version = RateLimitedJira::VERSION
  spec.authors = ["Christophe Broult"]
  spec.email = ["cbroult@yahoo.com"]

  spec.summary = "Transparent rate-limiting wrapper around jira-ruby's JIRA::Client."
  spec.homepage = "https://github.com/cbroult/rate-limited-jira-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject { |f| f.end_with?(".gem") || f == gemspec }
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "jira-ruby"
  spec.add_dependency "ratelimit"
  spec.add_dependency "redis"
  spec.add_dependency "ruby-limiter"
end
