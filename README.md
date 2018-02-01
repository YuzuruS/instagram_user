# InstagramUser

[![Gem Version](https://img.shields.io/gem/v/instagram_user.svg?style=flat)](http://badge.fury.io/rb/instagram_user)
[![Build Status](https://img.shields.io/travis/YuzuruS/instagram_user.svg?style=flat)](https://travis-ci.org/YuzuruS/instagram_user)
[![Coverage Status](https://img.shields.io/coveralls/YuzuruS/instagram_user.svg?style=flat)](https://coveralls.io/r/YuzuruS/instagram_user?branch=master)
[![Code Climate](https://img.shields.io/codeclimate/github/YuzuruS/instagram_user.svg?style=flat)](https://codeclimate.com/github/YuzuruS/instagram_user)

Client for the Instagram Web Service for getting list of followers and follows without Instagram API.  
It uses scraping and private api for instagram.  
It may be unusable in the future because of using private api in the future.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'instagram_user'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install instagram_user

## Usage

```ruby
cli = InstagramUser.new(user_name: 'yuzuru_dev', password: 'PASSWORD')

follows = cli.get_follows('yuzuru_dev')
# => ["yudsuzuk", "instagram"]

followers = cli.get_followers('yuzuru_dev')
# => ["yudsuzuk"]
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
