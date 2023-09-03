$LOAD_PATH.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |spec|
  spec.name        = 'vagrant-vultr'
  spec.version     = '0.1.3'
  spec.author      = 'Alex Rodionov'
  spec.email       = 'p0deje@gmail.com'
  spec.homepage    = 'http://github.com/p0deje/vagrant-vultr'
  spec.summary     = 'Vultr provider for Vagrant'
  spec.description = 'Vagrant plugin to use Vultr as provider'
  spec.license     = 'MIT'

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  spec.require_paths = %w[lib]

  spec.add_dependency 'vultr', '0.3.5'

  spec.add_development_dependency 'aruba'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
end
