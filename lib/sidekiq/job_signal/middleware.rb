# frozen_string_literal: true

module Sidekiq
  module JobSignal
    class Middleware
      def call(worker, _job, _queue)
        if ::Sidekiq.redis { |r| r.get "jobsignal-#{worker.jid}" }
          def worker.perform(*args)
            ::Sidekiq.logger.info "Turned #{jid}:#{self.class} into a no-op: #{args.inspect}"
          end
        end

        yield
      end
    end
  end
end
