# Custom Rollouts

This is a gem like [rollout](https://github.com/fetlife/rollout) that lets you
create create feature flags. But with traditional feature flags, the
flag is either on or off. This gem allows for more complex states.

## Usage

Create a redis connection to store data in:

```rb
require 'redis'

redis = Redis.new
```

To do normal percentage-based flags:

```rb
feature = CustomRollout.percentage(key: "awesome_feature", store: redis)
feature.percentage = 30

def do_stuff(user)
  if feature.enabled?(user.id.to_s)
    # 30% chance of this path
    do_new_stuff
  else
    # 70% chance of this path
    do_old_stuff
  end
end
```

But suppose you want to do something more complicated. For instance, suppose
your trying to migrate traffic from one database to another but you need to
warm up the caches with production-like queries before you can start actually
using the new database. Then you can use a warmup feature:

```rb
feature = CustomRollout.warmup(key: "awesome_warmup_feature", store: redis)

def do_stuff(request)
  case feature.state(request.uuid)
    when CustomRollout::DISABLED
      query_old_database
    when CustomRollout::ENABLED
      query_new_database
    when CustomRollout::WARMUP
      # Return results from the old database but run the same queries on the
      # new database in the background to warm it up.
      in_background { query_new_database }
      query_old_database
    when CustomRollout::COOLDOWN
      # If we've stopped sending queries to the old database, we need to warm
      # the old database back up before rolling back.
      in_background { query_old_database }
      query_new_database
  end
end

feature.warmup_percentage = 10
feature.enable_warmed
feature.warmup_percentage = 30
puts feature.percentages
# => {:enabled=>10.0, :disabled=>60.0, :warmup=>30.0, :cooldown=>0.0}
feature.enable_warmed
feature.cooldown_percentage = 15
puts feature.percentages
# => {:enabled=>25.0, :disabled=>60.0, :warmup=>0.0, :cooldown=>15.0}
```

## Development

To test flags without using redis, you can use `CustomRollout::MemoryStore`:

```rb
require 'custom_rollout'
require 'custom_rollout/memory_store'

feature = CustomRollout.warmup(key: "awesome_warmup_feature", store: CustomRollout::MemoryStore.new)
```

Using irb:

```sh
irb -Ilib -rcustom_rollout.rb -rcustom_rollout/memory_store.rb
```
