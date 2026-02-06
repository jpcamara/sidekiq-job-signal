## [Unreleased]

## [0.2.0] - 2026-02-06

### Breaking Changes

- **Minimum Ruby version increased to 2.7.0** (was 2.6.0)
- **Minimum Sidekiq version increased to 7.3** (was 6.5)
- **Dropped support for Sidekiq 6.x** - Users on Sidekiq 6.x should stay on sidekiq-job-signal 0.1.x
- **Note**: Sidekiq 8.0+ requires Ruby 3.2+, enforced by Sidekiq itself

### Added

- **Sidekiq 8.0+ support** - Full compatibility with Sidekiq 8.x releases
- **New `Sidekiq::JobSignal.register_web_ui` helper method** - Automatically detects Sidekiq version and uses the appropriate Web UI registration pattern
- **Version detection** - The gem automatically detects whether you're using Sidekiq 7.x or 8.0+ and handles registration accordingly

### Changed

- Updated Sidekiq dependency to support versions 7.3 through 8.x: `">= 7.3", "< 9.0"`
- Updated required Ruby version to match Sidekiq 7.3 requirements: `">= 2.7.0"` (Note: Sidekiq 8.0+ requires Ruby 3.2+)
- Enhanced README with comprehensive upgrade guide and migration instructions
- Updated Web UI registration documentation to show all supported patterns

### Migration Guide

1. Ensure you're on Ruby 2.7 or higher (Ruby 3.2+ required if using Sidekiq 8.0+)
2. Upgrade Sidekiq to 7.3 or higher: `bundle update sidekiq`
3. Update sidekiq-job-signal to 0.2.0: `bundle update sidekiq-job-signal`
4. (Optional) Update your Web UI registration to use the new helper method:
   ```ruby
   # Old (still works):
   Sidekiq::Web.register Sidekiq::JobSignal::Web

   # New (recommended):
   Sidekiq::JobSignal.register_web_ui
   ```

### Technical Details

The core middleware and Redis operations were already compliant with Sidekiq 7.3+ and 8.0+ APIs:
- Already using modern Redis pipelining syntax: `r.pipelined do |pipeline|`
- Already using correct ServerMiddleware API with proper `call(job, job_payload, queue)` signature
- Only accesses stable job properties (`jid`, `class.name`) unaffected by internal changes

The main changes were:
1. Updating version constraints in gemspec
2. Adding Web UI registration helper with version detection
3. Comprehensive documentation updates

## [0.1.0] - 2023-04-02

- Initial release
