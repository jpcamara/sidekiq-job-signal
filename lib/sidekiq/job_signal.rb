# frozen_string_literal: true

require "sidekiq"
require_relative "job_signal/version"
require_relative "job_signal/server_middleware"
require_relative "job_signal/receiver"
require_relative "job_signal/web"

module Sidekiq
  module JobSignal
    class << self
      def handlers
        @handlers ||= []
      end

      def on_quit(&block)
        handlers << block
      end

      def quit(job_class: "", jid: "")
        ::Sidekiq.redis do |r|
          r.pipelined do |pipeline|
            pipeline.set "jobsignal-#{jid}", "quit", ex: 86_400 if jid && !jid.empty?
            pipeline.set "jobsignal-#{job_class}", "quit", ex: 86_400 if job_class && !job_class.empty?
          end
        end
      end

      def delete_signal(job_class: "", jid: "")
        ::Sidekiq.redis do |r|
          r.pipelined do |pipeline|
            pipeline.del("jobsignal-#{jid}") if jid && !jid.empty?
            pipeline.del("jobsignal-#{job_class}") if job_class && !job_class.empty?
          end
        end
      end

      def quitting?(job_class: "", jid: "")
        results = ::Sidekiq.redis do |r|
          r.pipelined do |pipeline|
            pipeline.get("jobsignal-#{jid}") if jid && !jid.empty?
            pipeline.get("jobsignal-#{job_class}") if job_class && !job_class.empty?
          end
        end
        results.include?("quit")
      end
    end
  end
end
