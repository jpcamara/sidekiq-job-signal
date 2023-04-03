# frozen_string_literal: true

require_relative "job_signal/version"
require_relative "job_signal/middleware"

module Sidekiq
  module JobSignal
    class Error < StandardError; end
  end
end
