lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "instagram_user/version"

Gem::Specification.new do |spec|
  spec.name          = "instagram_user"
  spec.version       = InstagramUser::VERSION
  spec.authors       = ["Yuzuru Suzuki"]
  spec.email         = ["navitima@gmail.com"]

  spec.summary       = "Client for the Instagram using scraping"
  spec.description   = "Client for the Instagram Web Service without Instagram API. Implemented in Ruby using the Selenium and Mechanize module."
  spec.homepage      = "https://github.com/YuzuruS/instagram_user"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'mechanize'
  spec.add_dependency 'selenium-webdriver'
  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "terminal-notifier"
  spec.add_development_dependency "terminal-notifier-guard"
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'ffi', '1.9.18'
end
