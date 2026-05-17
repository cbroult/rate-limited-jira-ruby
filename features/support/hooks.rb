# frozen_string_literal: true

Before do
  setup_aruba
  ENV["HOME"] = expand_path(".")
  cd(".")
  %w[JIRA_USERNAME JIRA_API_TOKEN JIRA_SITE_URL JIRA_CONTEXT_PATH].each do |var|
    set_environment_variable(var, ENV[var]) if ENV[var]
  end
end
