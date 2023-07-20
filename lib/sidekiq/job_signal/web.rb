# # frozen_string_literal: true

module Sidekiq
  module JobSignal
    module Web
      ROOT = File.expand_path("../../../../web", __FILE__)

      def self.registered(app)
        app.get "/signals" do
          render(:erb, File.read("#{ROOT}/views/signals.erb"))
        end

        app.post "/signals" do
          Sidekiq::JobSignal.quit(jid: params["quit"]) if params["quit"]
          render(:erb, File.read("#{ROOT}/views/signals.erb"))
        end
        app.tabs["Signals"] = "signals"
      end
    end
  end
end