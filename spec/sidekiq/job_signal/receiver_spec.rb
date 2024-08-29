# frozen_string_literal: true

require "sidekiq"
require "spec_helper"

class ReceiverExampleJob
  include Sidekiq::Job
  include Sidekiq::JobSignal::Receiver
end

RSpec.describe Sidekiq::JobSignal::Receiver do
  let(:receiver) { ReceiverExampleJob.new }

  before do
    allow(receiver).to receive(:jid).and_return("123")
  end

  after do
    Sidekiq::JobSignal.delete_signal(jid: "123", job_class: "ReceiverExampleJob")
  end

  describe "#quitting?" do
    it "returns true if the `jid` key is set" do
      Sidekiq::JobSignal.quit(jid: "123")
      expect(receiver.quitting?).to be true
    end

    it "returns true if the `job_class` key is set" do
      Sidekiq::JobSignal.quit(job_class: "ReceiverExampleJob")
      expect(receiver.quitting?).to be true
    end

    it "returns false if the `job_class` or `jid` is not accurate" do
      Sidekiq::JobSignal.quit(job_class: "ReceiverExample2Job", jid: "234")
      expect(receiver.quitting?).to be false
    end

    it "returns false if the key is not set" do
      expect(receiver.quitting?).to be false
    end
  end
end
