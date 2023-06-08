# frozen_string_literal: true

require "sidekiq"
require "spec_helper"

# write a spec for lib/sidekiq/job_signal.rb
RSpec.describe Sidekiq::JobSignal do
  after do
    Sidekiq::JobSignal.delete_signal(jid: "123")
  end

  it "has a version number" do
    expect(described_class::VERSION).not_to be nil
  end

  # describe ".on_quit" do
  #   it "adds a handler" do
  #     expect { |b| described_class.on_quit(&b) }.to yield_control
  #   end
  # end

  describe ".quit" do
    it "sets a redis key" do
      described_class.quit(jid: "123")
      expect(Sidekiq.redis { |r| r.get("jobsignal-123") }).to eq "quit"
    end
  end

  describe ".quitting?" do
    it "returns true if the key is set" do
      described_class.quit(jid: "123")
      expect(described_class.quitting?(jid: "123")).to be true
    end

    it "returns false if the key is not set" do
      expect(described_class.quitting?(jid: "123")).to be false
    end
  end
end
