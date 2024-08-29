# frozen_string_literal: true

module Sidekiq
  module JobSignal
    module Receiver
      def quitting?
        ::Sidekiq::JobSignal.quitting?(jid: jid, job_class: self.class.name)
      end
    end
  end
end
