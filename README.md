# Statisfaction

The Statisfaction Ruby Gem provides an easy way to store and retrieve statistics on the usage of methods.

You can specify which methods are watched, see the Usage section for examples.

## Installation

Add this line to your application's Gemfile:

    gem 'statisfaction'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install statisfaction

To setup Statisfaction in your application:

    $ rails generate statisfaction:install

This process
* creates a migration,
* adds an initializer that denies everybody view access to Statisfaction data:
```ruby
  Statisfaction.configure do
      viewable_if { false }
  end
```

  Don't forget to grant access :) The block has access to any instance methods that are present in ApplicationController (and, if you really want it, StatisfactionController).

Now run

    $ rake db:migrate

and you're done!

## Usage

### Collecting information

Methods for which statistics are collected are configured in the class itself by calling

```ruby
class MyClass
  statisfy do
    record :my_method
    record :another_method
  end
end
```

This records when :my_method and :another_method are called on instances of MyClass. Of course, a shorthand is available in the form of

```ruby
class MyClass
  statisfy do
    record :my_method, :another_method
  end
end
```

There are also some sensible defaults for ActiveRecord: create, update, destroy:

```ruby
class MyAR < ActiveRecord::Base
  statisfy
end
```
which is equivalent to
```ruby
class MyAR < ActiveRecord::Base
  statisfy do
    statisfaction_defaults
  end
end
```

The second form also allows collecting other methods in addition to the defaults:
```ruby
class MyAR < ActiveRecord::Base
  statisfy do
    statisfaction_defaults

    # You can still add your own methods to record
    record :my_method
    record :another_method
  end
end
```

You can specify an attribute to be recorded when the specified method is called:

```ruby
class MyClass
  attr_accessor :user

  statisfy do
    record :my_method, storing: :user
  end
end
```

If you want to record the same attribute for multiple methods, you can specify a default attribute:

```ruby
class MyClass
  attr_accessor :user, :another_attribute

  statisfy(storing: :user) do
    record :my_method
    record :another_method

    # for calls to :yet_another_method, do not store
    # user, but :another_attribute
    record :yet_another_method, storing: :another_attribute
  end
end
```

Some time in the future, we'd like to support blocks as well:

```ruby
class MyClass
  statisfy(recording: :user) do
    # NOTE: This is not supported yet
    record :my_method, storing: proc { User.find(params[:id]) }
  end
end
```

### Retrieving statistics

Statisfaction exposes a JSON API which allows you to retrieve statistics from your application.

By default, by issuing a GET request like

    /statisfaction/get.json?for[]=MyClass,create&for[]=MyClass,destroy&start=2012-01-01&end=2012-05-01&granularity=month

you retrieve statistics for the :create and :destroy method on MyClass.

This path is accessible on the server side as

```ruby
statisfaction.get_path( {
  for: %w{MyClass,create MyClass,destroy},
  start: "2012-01-01",
  end: "2012-05-01",
  granularity: :month
} )
```

#### Note

In Rails 3.0, this path is called 'statisfaction_get_path" instead, since the engine's routes cannot be properly mounted prior to Rails 3.1

#### Parameters

|name       | description                            |
|-----------|----------------------------------------|
|for[]      | a list of *class,method*-tuples        |
|start, end | a datetime in ISO8601 format           |
|granularity| 'hour', 'day', 'week', 'month', 'year' |

All parameters are mandatory.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
