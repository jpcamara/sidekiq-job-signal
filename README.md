# Sidekiq Job Signal

Signal a job to quit, and block the job from executing through middleware.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add sidekiq-job-signal

In your Gemfile, specify the gem as:

    gem "sidekiq-job-signal", require: "sidekiq/job_signal"

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install sidekiq-job-signal

## Usage

```rb
Sidekiq::JobSignal.quit(jid: "12345")
Sidekiq::JobSignal.quit(job_class: "ExampleJob")

# log:
#   Turned #{12345}:#{JobWorkerClass} into a no-op: [1,2,3]"

# If you want to add the `quitting?` method to your job
class ExampleJob
  include Sidekiq::Job
  include Sidekiq::JobSignal::Receiver

  def perform
    if quitting?
      # finish early...
    end
  end
end

# middleware.rb
Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    # Defaults to by_class: false, by_jid: true
    chain.add ::Sidekiq::JobSignal::ServerMiddleware
    # OR
    chain.add ::Sidekiq::JobSignal::ServerMiddleware, by_class: true
    # OR
    chain.add ::Sidekiq::JobSignal::ServerMiddleware, by_jid: false, by_class: true
  end

  Sidekiq::JobSignal.on_quit do |job|
    Sidekiq.logger.info "Job was cancelled!"
    Sidekiq.logger.info job
  end
end
```

If you'd like to enable the Sidekiq Web UI for quitting jobs, you can include the following in some kind of initialization file. This will enable a new "Signals" tab.

```rb
Sidekiq::Web.register Sidekiq::JobSignal::Web
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jpcamara/sidekiq-job-signal. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/jpcamara/sidekiq-job-signal/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Sidekiq::Job::Signal project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/jpcamara/sidekiq-job-signal/blob/main/CODE_OF_CONDUCT.md).
