# Itamae::Plugin::Recipe::Mackerel::Agent

[![Gem Version](https://badge.fury.io/rb/itamae-plugin-recipe-mackerel-agent.svg)](https://badge.fury.io/rb/itamae-plugin-recipe-mackerel-agent)

[Itamae](https://github.com/itamae-kitchen/itamae) recipe plugin for [mackerel-agent](https://github.com/mackerelio/mackerel-agent)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'itamae-plugin-recipe-mackerel-agent'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install itamae-plugin-recipe-mackerel-agent

## Usage

Load the recipe file in gems by `include_recipe`.

```ruby
include_recipe "mackerel-agent"

# Option for installation of mackerel-agent-plugins package
package "mackerel-agent-plugins"

# Option for installation of mackerel-check-plugins package
package "mackerel-check-plugins"
```

## Attributes

```ruby
# API key (REQUIRED)
node['mackerel-agent']['conf']['apikey'] = 'YOUR API KEY'

# Roles (optional)
node['mackerel-agent']['conf']['roles'] = ["My-Service:app", "Another-Service:db"]

# Plugins (optional)
node['mackerel-agent']['conf']['plugin.metrics.vmstat'] = {
  'command' => 'ruby /etc/sensu/plugins/system/vmstat-metrics.rb',
}
```

## Contributing

1. Fork it ( https://github.com/mackerelio/itamae-plugin-recipe-mackerel-agent/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
