# frozen_string_literal: true

require_relative "job_signal/version"
require_relative "job_signal/server_middleware"
require_relative "job_signal/receiver"

module Sidekiq
  module JobSignal
    class << self
      def handlers
        @handlers ||= []
      end

      def on_quit(&block)
        handlers << block
      end

      def quit(worker_class: "", jid: "")
        ::Sidekiq.redis do |r|
          r.pipelined do |pipeline|
            pipeline.set "jobsignal-#{jid}", "quit", ex: 86_400 if jid && !jid.empty?
            pipeline.set "jobsignal-#{worker_class}", "quit", ex: 86_400 if worker_class && !worker_class.empty?
          end
        end
      end

      def delete_signal(worker_class: "", jid: "")
        ::Sidekiq.redis do |r|
          r.pipelined do |pipeline|
            pipeline.del("jobsignal-#{jid}") if jid && !jid.empty?
            pipeline.del("jobsignal-#{worker_class}") if worker_class && !worker_class.empty?
          end
        end
      end

      def quitting?(worker_class: "", jid: "")
        results = ::Sidekiq.redis do |r|
          r.pipelined do |pipeline|
            pipeline.get("jobsignal-#{jid}") if jid && !jid.empty?
            pipeline.get("jobsignal-#{worker_class}") if worker_class && !worker_class.empty?
          end
        end
        results.include?("quit")
      end
    end
  end
end
