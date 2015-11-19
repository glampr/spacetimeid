# SpaceTimeId [Ruby]
A unique spationtemporal id implementation for use in nanocubes.

## General Requirements

Install via rubygems

```gem install spacetimeid```

or add it to your Gemfile

```gem 'spacetimeid'```

## Example

```ruby
require 'time'
time = Time.parse("2015-06-01T00:05:32Z")
id = SpaceTimeId.new(time.to_i, [1.3, -3.048])

id.id
# => "1433116800_1.30_-3.05"

# self.default_options = {
#   xy_base_step: 0.01,    # 0.01 degrees
#   xy_expansion: 5,       # expands into a 5x5 grid recursively
#   ts_steps:     [3600],  # [600, 1800, 3600, 21600, 86400] [10min, 0.5h, 1h, 6h, 1day]
#   ts_expansion: 2,       # expands 2 times each interval
#   decimals: 2
# }

```

### Disclaimer
This project is written on a need to use basis for inclusion to other projects I'm working on for now, so completion is not an immediate goal.
