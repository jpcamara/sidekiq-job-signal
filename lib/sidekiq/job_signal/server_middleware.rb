# frozen_string_literal: true

module Sidekiq
  module JobSignal
    class ServerMiddleware
      include ::Sidekiq::ServerMiddleware

      def call(worker, _job, _queue)
        signalled = ::Sidekiq::JobSignal.quitting?(worker_class: worker.class.name, jid: worker.jid)
        logger.info "Sidekiq::JobSignal::ServerMiddleware.call: signalled=#{signalled}"
        if signalled
          def worker.perform(*args)
            logger.info "Turned #{jid}:#{self.class} into a no-op: #{args.inspect}"
          end
        end

        yield
      ensure
        logger.info "Sidekiq::JobSignal::ServerMiddleware.call: ensure signalled=#{signalled}"
        ::Sidekiq::JobSignal.handlers.each { |handler| handler.call(worker) } if signalled
      end
    end
  end
end
