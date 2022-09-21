Pod::Spec.new do |s|

  s.name          = "PulseLogHandler"
  s.version       = "2.1.2"
  s.summary       = "Pulse is a powerful logging system for Apple Platforms. Native. Built with SwiftUI."
  s.swift_version = "5.6"

  s.description  = <<-DESC
  Pulse is a powerful logging system for Apple Platforms. Native. Built with SwiftUI.
  DESC

  s.homepage     = "https://github.com/kean/Pulse"
  s.license      = "MIT"
  s.author       = { "kean" => "https://github.com/kean" }
  s.authors      = { "kean" => "https://github.com/kean" }
  s.source       = { :git => "git@github.com:kean/Pulse.git", :tag => "#{s.version}" }
  s.social_media_url = "https://kean.blog/"

  s.ios.deployment_target = "13.0"
  s.source_files = "Sources/PulseLogHandler/**/*.swift"
  
  s.dependency "Pulse"
  s.dependency "Logging", "~> 1.2.0"
end
