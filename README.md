# InstagramUser

[![Gem Version](https://img.shields.io/gem/v/instagram_user.svg?style=flat)](http://badge.fury.io/rb/instagram_user)
[![Coverage Status](https://img.shields.io/coveralls/YuzuruS/instagram_user.svg?style=flat)](https://coveralls.io/r/YuzuruS/instagram_user?branch=master)
[![Maintainability](https://api.codeclimate.com/v1/badges/4aca4672a1a60538eef9/maintainability)](https://codeclimate.com/github/YuzuruS/instagram_user/maintainability)

Client for the Instagram Web Service without Instagram API.  
Implemented in Ruby using the Selenium and Mechanize module.

## Installation


```ruby
gem 'instagram_user'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install instagram_user

## Usage

```ruby
cli = InstagramUser.new(user_name: 'YOUR_USER_NAME', password: 'YOUR_PASSWORD')

# Get the follow list for the specified user
follows = cli.get_follows('instagram_user_name')
# => ["user_name1", "user_name2"...]

# Get the follower list for the specified user
followers = cli.get_followers('instagram_user_name')
# => ["user_name1", "user_name2"...]

# Follow the specified user
res = cli.create_follow('instagram_user_name')
# => true or false

# Unfollow the specified user
res = cli.delete_follow('instagram_user_name')
# => true or false

# get media for the specified tag
res = cli.get_medias_by_tag('japanesefood')
# => {"recent" => [...], "popularity" => [...]}
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the InstagramUser project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/YuzuruS/instagram_user/blob/master/CODE_OF_CONDUCT.md).
