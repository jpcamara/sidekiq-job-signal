# frozen_string_literal: true

require "sidekiq"
require "spec_helper"

RSpec.describe Sidekiq::JobSignal::Receiver do
  let(:receiver) { described_class.new }

  before do
    allow(receiver).to receive(:jid).and_return("123")
  end

  after do
    Sidekiq::JobSignal.delete_signal(jid: "123")
  end

  describe "#quitting?" do
    it "returns true if the key is set" do
      Sidekiq::JobSignal.quit(jid: "123")
      expect(receiver.quitting?).to be true
    end

    it "returns false if the key is not set" do
      expect(receiver.quitting?).to be false
    end
  end
end