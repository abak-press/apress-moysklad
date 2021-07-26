lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include? lib

require 'apress/moysklad/version'

Gem::Specification.new do |gem|
  gem.name         = 'apress-moysklad'
  gem.version      = Apress::Moysklad::VERSION
  gem.authors      = ['Korotaev Danil']
  gem.email        = %w(korotaev.danil@gmail.com)
  gem.summary      = 'Tools for synchronization with MoySklad online-service'
  gem.homepage     = 'https://github.com/abak-press/apress-moysklad'

  gem.files        = `git ls-files -z`.split("\x0")
  gem.test_files   = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_path = "lib"

  gem.add_runtime_dependency 'oj'

  gem.add_development_dependency 'bundler', '~> 1.6'
  gem.add_development_dependency 'rake', '< 11.0'  # https://github.com/lsegal/yard/issues/947
  gem.add_development_dependency 'rspec', '>= 3.5'
  gem.add_development_dependency 'rspec-its'
  gem.add_development_dependency 'rspec-collection_matchers'
  gem.add_development_dependency 'timecop'
  gem.add_development_dependency 'webmock'
  gem.add_development_dependency 'vcr'

  # test coverage tools
  gem.add_development_dependency 'simplecov', '~> 0.10.0'
end
