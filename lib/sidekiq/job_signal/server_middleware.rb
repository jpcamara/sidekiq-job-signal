# frozen_string_literal: true

module Sidekiq
  module JobSignal
    class ServerMiddleware
      include ::Sidekiq::ServerMiddleware

      def initialize(options = {})
        @by_jid = options.fetch(:by_jid, true)
        @by_class = options.fetch(:by_class, false)
      end

      def call(job, job_payload, _queue)
        signalled = ::Sidekiq::JobSignal.quitting?(**quit_options(job))
        logger.debug "#{self.class}.call: signalled=#{signalled}"
        noop_job(job) if signalled
        yield
      ensure
        logger.debug "#{self.class}.call: ensure signalled=#{signalled}"
        ::Sidekiq::JobSignal.handlers.each { |handler| handler.call(job) } if signalled
      end

      private

      attr_reader :by_jid, :by_class

      def quit_options(job)
        {}.tap do |options|
          options[:job_class] = job.class.name if by_class
          options[:jid] = job.jid if by_jid
        end
      end

      def noop_job(job)
        def job.perform(*args)
          logger.info "Turned #{jid}:#{self.class} into a no-op: #{args.inspect}"
        end
      end
    end
  end
end
