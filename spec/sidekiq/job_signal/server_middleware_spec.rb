# frozen_string_literal: true

require "sidekiq"
require "spec_helper"

RSpec.describe Sidekiq::JobSignal::ServerMiddleware do
  let(:worker) { double("worker", jid: "123", empty?: false) }
  let(:job) { double("job", empty?: false) }
  let(:queue) { double("queue") }
  let(:middleware) { Sidekiq::JobSignal::ServerMiddleware.new }

  before do
    allow(worker).to receive(:perform)
  end

  after do
    Sidekiq::JobSignal.delete_signal(jid: "123")
  end

  describe "#call" do
    context "when the job is cancelled" do
      before do
        Sidekiq::JobSignal.quit(jid: "123")
      end

      it "redefines the perform method" do
        expect(worker).to receive(:perform).never
        middleware.call(worker, job, queue) {}
      end

      it "calls the handlers" do
        expect { |b| Sidekiq::JobSignal.on_quit(&b) }.to yield_control
        middleware.call(worker, job, queue) {}
      end
    end

    context "when the job is not cancelled" do
      it "does not redefine the perform method" do
        expect(worker).to receive(:perform)
        middleware.call(worker, job, queue) {}
      end

      it "does not call the handlers" do
        expect { |b| Sidekiq::JobSignal.on_quit(&b) }.not_to yield_control
        middleware.call(worker, job, queue) {}
      end
    end
  end
end