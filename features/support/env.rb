# frozen_string_literal: true

require "aruba/cucumber"

ENV["PATH"] = File.join(__dir__, "..", "..", "bin") + File::PATH_SEPARATOR + ENV.fetch("PATH", nil)
