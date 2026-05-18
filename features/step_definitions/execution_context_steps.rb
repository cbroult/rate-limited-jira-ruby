# frozen_string_literal: true

BUFFER_TIME_IN_SECONDS = 10

Given(/^the following environment variables are set:$/) do |table|
  table.hashes.each do |row|
    set_environment_variable(row.fetch("name"), row.fetch("value"))
  end
end

Then(/^successfully running `(.*)` takes between (.*) and (.*) seconds$/) do |cmd, min, max|
  start_time = Time.now
  run_command_and_stop(cmd, fail_on_error: true, exit_timeout: max.to_i + BUFFER_TIME_IN_SECONDS)
  end_time = Time.now
  expect(end_time - start_time).to be_between(min.to_i, max.to_i)
end
