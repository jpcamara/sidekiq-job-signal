# frozen_string_literal: true

require "sidekiq"
require "spec_helper"

RSpec.describe Sidekiq::JobSignal do
  after do
    Sidekiq::JobSignal.delete_signal(jid: "123")
    Sidekiq::JobSignal.delete_signal(job_class: "ExampleJob")
  end

  it "has a version number" do
    expect(described_class::VERSION).not_to be nil
  end

  describe ".on_quit" do
    it "adds a handler" do
      on_quit1 = -> {}
      on_quit2 = -> {}
      described_class.on_quit(&on_quit1)
      described_class.on_quit(&on_quit2)
      expect(described_class.handlers.find(on_quit1)).to be_truthy
      expect(described_class.handlers.find(on_quit2)).to be_truthy
    end
  end

  describe ".quit" do
    it "sets a redis key" do
      described_class.quit(jid: "123")
      described_class.quit(job_class: "ExampleJob")
      expect(Sidekiq.redis { |r| r.get("jobsignal-123") }).to eq "quit"
      expect(Sidekiq.redis { |r| r.get("jobsignal-ExampleJob") }).to eq "quit"
    end
  end

  describe ".quitting?" do
    it "returns true if the key is set" do
      described_class.quit(jid: "123", job_class: "ExampleJob")
      expect(described_class.quitting?(jid: "123")).to be true
      expect(described_class.quitting?(job_class: "ExampleJob")).to be true
    end

    it "returns false if the key is not set" do
      expect(described_class.quitting?(jid: "123")).to be false
      expect(described_class.quitting?(job_class: "ExampleJob")).to be false
    end
  end
end
