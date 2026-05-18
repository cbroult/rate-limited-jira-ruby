## [Unreleased]

## [0.1.0] - 2026-05-18

- Initial release: transparent rate-limiting wrapper around jira-ruby's JIRA::Client
- In-process implementation using ruby-limiter
- Redis-based implementation using ratelimit + redis
- `RateLimitedJira::Client.build` factory; blank/nil implementation normalised to `:in_process`
