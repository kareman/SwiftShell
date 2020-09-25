Pod::Spec.new do |s|
  s.name         = 'SwiftShell'
  s.version      = '5.1.0'
  s.summary      = 'A Swift framework for shell scripting.'
  s.description  = 'SwiftShell is a library for creating command-line applications and running shell commands in Swift.'
  s.homepage     = 'https://github.com/kareman/SwiftShell'
  s.license      = { type: 'MIT', file: 'LICENSE.txt' }
  s.author = { 'Kare Morstol' => 'kare@nottoobadsoftware.com' }
  s.source = { git: 'https://github.com/kareman/SwiftShell.git', tag: s.version.to_s }
  s.source_files = 'Sources/SwiftShell/*.swift','Sources/SwiftShell/*/*.swift'
  s.osx.deployment_target = '10.11'
end
