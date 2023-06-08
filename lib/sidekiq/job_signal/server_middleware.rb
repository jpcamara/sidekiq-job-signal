# frozen_string_literal: true

module Sidekiq
  module JobSignal
    class ServerMiddleware
      def call(worker, _job, _queue)
        signalled = ::Sidekiq::JobSignal.quitting?(worker_class: worker.class.name, jid: worker.jid)
        ::Sidekiq.logger.info "Sidekiq::JobSignal::ServerMiddleware.call: signalled=#{signalled}"
        if signalled
          def worker.perform(*args)
            ::Sidekiq.logger.info "Turned #{jid}:#{self.class} into a no-op: #{args.inspect}"
          end
        end

        yield
      ensure
        ::Sidekiq.logger.info "Sidekiq::JobSignal::ServerMiddleware.call: ensure signalled=#{signalled}"
        ::Sidekiq::JobSignal.handlers.each { |handler| handler.call(worker) } if signalled
      end
    end
  end
end
