# frozen_string_literal: true

module Sidekiq
  module JobSignal
    class ServerMiddleware
      def call(worker, _job, _queue)
        signalled = ::Sidekiq::JobSignal.cancelled?(worker.jid)
        if signalled
          def worker.perform(*args)
            ::Sidekiq.logger.info "Turned #{jid}:#{self.class} into a no-op: #{args.inspect}"
            # ::Sidekiq::JobSignal.handlers.each { |handler| handler.call(worker) }
          end
        end

        yield
      ensure
        ::Sidekiq::JobSignal.handlers.each { |handler| handler.call(worker) } if signalled
      end
    end
  end
end
