Gem::Specification.new do |s|
  s.name          = 'mullvadrb'
  s.version       = '0.0.6'
  s.summary       = 'A TUI to use with Mullvad VPN'
  s.description   = 'A Terminal User Interface to use with Mullvad VPN'
  s.authors       = ['Fernando Briano']
  s.email         = 'fernando@picandocodigo.net'
  s.files         = `git ls-files`.split($/)
  s.require_paths = ['lib']
  s.homepage      = 'https://github.com/picandocodigo/mullvad-ruby'
  s.license       = 'GPL-3.0-only'
  s.required_ruby_version = '>= 3.0'
  s.executables << 'mullvadrb'
  s.add_dependency 'countries'
  s.add_dependency 'i18n', '~> 1'
  s.add_dependency 'tty-prompt'
  s.metadata = {
    'bug_tracker_uri' => 'https://github.com/picandocodigo/mullvadrb/issues',
    'changelog_uri' => 'https://github.com/picandocodigo/mullvadrb/blob/master/CHANGELOG.md',
    'source_code_uri' => 'https://github.com/picandocodigo/mullvadrb'
  }
end
