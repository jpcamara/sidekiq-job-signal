# frozen_string_literal: true

require_relative "lib/sidekiq/job_signal/version"
require_relative "lib/sidekiq/job_signal/middleware"
require_relative "lib/sidekiq/job_signal"

Gem::Specification.new do |spec|
  spec.name = "sidekiq-job-signal"
  spec.version = Sidekiq::JobSignal::VERSION
  spec.authors = ["JP Camara"]
  spec.email = ["48120+jpcamara@users.noreply.github.com"]

  spec.summary = "Signal a job to quit, and block the job from executing through middleware."
  spec.description = "Signal a job to quit, and block the job from executing through middleware."
  spec.homepage = "https://github.com/jpcamara/sidekiq-job-signal"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/jpcamara/sidekiq-job-signal"
  spec.metadata["changelog_uri"] = "https://github.com/jpcamara/sidekiq-job-signal"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
