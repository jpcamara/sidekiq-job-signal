# Sidekiq Job Signal

Signal a job to quit, and block the job from executing through middleware.

## Requirements

- Ruby 2.7+ (Ruby 3.2+ required for Sidekiq 8.0+)
- Sidekiq 7.3 - 8.x
- Redis 7.0+ (or compatible)

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
# Recommended: Use the helper method that works with both Sidekiq 7.x and 8.0+
Sidekiq::JobSignal.register_web_ui

# Or for Sidekiq 8.0+ you can use the new configuration pattern directly:
Sidekiq::Web.configure do |config|
  config.register(Sidekiq::JobSignal::Web)
end

# Or for Sidekiq 7.x you can use the legacy pattern (still supported):
Sidekiq::Web.register(Sidekiq::JobSignal::Web)
```

## Upgrading from 0.1.x to 1.0.0

Version 1.0.0 introduces breaking changes to support Sidekiq 7.3+ and 8.0+:

### Breaking Changes

1. **Minimum Ruby version increased**: Now requires Ruby 2.7+ (was 2.6+)
2. **Minimum Sidekiq version increased**: Now requires Sidekiq 7.3+ (was 6.5+)
3. **Dropped Sidekiq 6.x support**: If you're on Sidekiq 6.x, stay on sidekiq-job-signal 0.1.x

### Migration Steps

1. Ensure you're on Ruby 2.7 or higher (Ruby 3.2+ required if using Sidekiq 8.0+)
2. Upgrade Sidekiq to 7.3 or higher: `bundle update sidekiq`
3. Update sidekiq-job-signal to 1.0.0: `bundle update sidekiq-job-signal`
4. (Optional) Update your Web UI registration to use the new helper method:
   ```rb
   # Old (still works):
   Sidekiq::Web.register Sidekiq::JobSignal::Web

   # New (recommended):
   Sidekiq::JobSignal.register_web_ui
   ```

### What's New

- **Sidekiq 8.0+ support**: Full compatibility with the latest Sidekiq 8.x releases
- **Version detection**: The gem automatically detects your Sidekiq version and uses the appropriate Web UI registration method
- **Helper method**: New `Sidekiq::JobSignal.register_web_ui` method for simplified Web UI setup

### Staying on 0.1.x

If you need to stay on Sidekiq 6.x or Ruby < 2.7, you can pin to version 0.1.x in your Gemfile:

```rb
gem "sidekiq-job-signal", "~> 0.1.0", require: "sidekiq/job_signal"
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
