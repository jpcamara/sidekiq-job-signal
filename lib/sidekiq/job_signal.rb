# frozen_string_literal: true

require_relative "job_signal/version"
require_relative "job_signal/server_middleware"

module Sidekiq
  module JobSignal
    class Error < StandardError; end

    class Receiver
      def cancelled?
        ::Sidekiq::JobSignal.cancelled?(jid)
      end
    end

    class << self
      def handlers
        @handlers ||= []
      end

      def on_quit(&block)
        handlers << block
      end

      def cancel(jid)
        ::Sidekiq.redis { |r| r.set "jobsignal-#{jid}", "quit", ex: 86_400 }
      end

      def cancelled?(jid)
        ::Sidekiq.redis { |r| r.get("jobsignal-#{jid}") } == "quit"
      end
    end
  end
end
