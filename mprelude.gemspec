# frozen_string_literal: true

Gem::Specification.new do |gem|
  gem.name        = 'mprelude'
  gem.version     = '0.1.0'
  gem.authors     = ['Markus Schirp']
  gem.email       = ['mbj@schirp-dso.com']
  gem.description = 'Minimal prelude alike classes'
  gem.summary     = 'Mostly an either type'
  gem.homepage    = 'https://github.com/mbj/mprelude-rb'
  gem.licenses    = 'MIT'

  gem.require_paths = %w[lib]

  gem.files            = `git ls-files`.split("\n")
  gem.test_files       = `git ls-files -- spec/unit`.split("\n")
  gem.extra_rdoc_files = %w[LICENSE]

  gem.add_runtime_dependency('abstract_type',  '~> 0.0.7')
  gem.add_runtime_dependency('adamantium',     '~> 0.2.0')
  gem.add_runtime_dependency('concord',        '~> 0.1.5')
  gem.add_runtime_dependency('equalizer',      '~> 0.0.9')
  gem.add_runtime_dependency('ice_nine',       '~> 0.11.1')
  gem.add_runtime_dependency('procto',         '~> 0.0.2')

  gem.add_development_dependency('mutant',       '~> 0.11.16')
  gem.add_development_dependency('mutant-rspec', '~> 0.11.16')
  gem.add_development_dependency('rspec',        '~> 3.0')
  gem.add_development_dependency('rspec-its',    '~> 1.3')
end
