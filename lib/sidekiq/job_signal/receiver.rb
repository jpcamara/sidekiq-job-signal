# frozen_string_literal: true

module Sidekiq
  module JobSignal
    class Receiver
      def quitting?
        ::Sidekiq::JobSignal.quitting?(jid: jid, worker_class: self.class.name)
      end
    end
  end
end
