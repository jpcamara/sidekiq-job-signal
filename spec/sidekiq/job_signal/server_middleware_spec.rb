# frozen_string_literal: true

require "sidekiq"
require "spec_helper"

class SidekiqSignalExampleJob
  include Sidekiq::Job

  def perform(*args)
  end
end

RSpec.describe Sidekiq::JobSignal::ServerMiddleware do
  let(:job_payload) { {} }
  let(:queue) { double("queue") }
  let(:config) { instance_double("Config", logger: logger) }
  let(:logger) do
    instance_double(
      "Logger",
      info: ->(msg) { puts msg },
      debug: ->(msg) { puts msg }
    )
  end
  let(:middleware) do
    Sidekiq::JobSignal::ServerMiddleware.new.tap do |middleware|
      middleware.config = config
    end
  end
  let(:job) do
    job = SidekiqSignalExampleJob.new
    job.jid = "123"
    job
  end

  before do
    allow(job).to receive(:perform)
  end

  after do
    Sidekiq::JobSignal.delete_signal(jid: "123")
  end

  describe "#call" do
    context "when changing constructor params" do
      before do
        allow(::Sidekiq::JobSignal).to receive(:quitting?)
      end

      it "uses `by_class` when specified" do
        m = Sidekiq::JobSignal::ServerMiddleware.new(
          by_class: true, by_jid: false
        ).tap do |middleware|
          middleware.config = config
        end
        m.call(job, job_payload, queue) {}
        expect(::Sidekiq::JobSignal).to have_received(:quitting?).with(job_class: "SidekiqSignalExampleJob")
      end

      it "uses `jid` when specified" do
        m = Sidekiq::JobSignal::ServerMiddleware.new(by_jid: true).tap do |middleware|
          middleware.config = config
        end
        m.call(job, job_payload, queue) {}
        expect(::Sidekiq::JobSignal).to have_received(:quitting?).with(jid: "123")
      end

      it "uses `jid` when nothing is specified" do
        m = Sidekiq::JobSignal::ServerMiddleware.new.tap do |middleware|
          middleware.config = config
        end
        m.call(job, job_payload, queue) {}
        expect(::Sidekiq::JobSignal).to have_received(:quitting?).with(jid: "123")
      end

      it "uses `job_class` and `jid` when specified" do
        m = Sidekiq::JobSignal::ServerMiddleware.new(
          by_class: true, by_jid: true
        ).tap do |middleware|
          middleware.config = config
        end
        m.call(job, job_payload, queue) {}
        expect(::Sidekiq::JobSignal).to have_received(:quitting?).with(
          job_class: "SidekiqSignalExampleJob",
          jid: "123"
        )
      end
    end

    context "when the job is cancelled" do
      before do
        Sidekiq::JobSignal.quit(jid: "123")
      end

      it "logs debug message about the signal" do
        allow(logger).to receive(:debug)
        middleware.call(job, job_payload, queue) {}
        expect(logger).to have_received(:debug).with(
          "Sidekiq::JobSignal::ServerMiddleware.call: signalled=true"
        )
        expect(logger).to have_received(:debug).with(
          "Sidekiq::JobSignal::ServerMiddleware.call: ensure signalled=true"
        )
      end

      it "redefines the perform method" do
        middleware.call(job, job_payload, queue) {}
        job.perform
        expect(job).to_not have_received(:perform)
      end

      it "logs the no-op message" do
        allow(job.logger).to receive(:info)
        middleware.call(job, job_payload, queue) {}
        job.perform(2, 3, "4")
        expect(job.logger).to have_received(:info).with(
          "Turned 123:#{job.class} into a no-op: [2, 3, \"4\"]")
      end

      it "calls the handlers" do
        expect { |b|
          Sidekiq::JobSignal.on_quit(&b)
          middleware.call(job, job_payload, queue) {}
        }.to yield_control
      end
    end

    context "when the job is not cancelled" do
      it "logs debug message about the signal" do
        allow(logger).to receive(:debug)
        middleware.call(job, job_payload, queue) {}
        expect(logger).to have_received(:debug).with(
          "Sidekiq::JobSignal::ServerMiddleware.call: signalled=false"
        )
        expect(logger).to have_received(:debug).with(
          "Sidekiq::JobSignal::ServerMiddleware.call: ensure signalled=false"
        )
      end

      it "does not redefine the perform method" do
        middleware.call(job, job_payload, queue) {}
        job.perform
        expect(job).to have_received(:perform)
      end

      it "does not call the handlers" do
        expect do |b|
          Sidekiq::JobSignal.on_quit(&b)
          middleware.call(job, job_payload, queue) {}
        end.not_to yield_control
      end
    end
  end
end
