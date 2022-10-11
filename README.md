<br/>
<img width="2100" alt="01" src="https://user-images.githubusercontent.com/1567433/184552586-dd8cce3a-7ae1-494d-bbe9-41cfb1617c50.png">

**Pulse** is a powerful logging system for Apple Platforms. Native. Built with SwiftUI.

Record and inspect logs and `URLSession` network requests right from your iOS app using Pulse Console. Share and view logs in Pulse macOS app. Logs are recorded locally and never leave your device. [Learn more](https://kean.blog/pulse/home).

> Try [Get](https://github.com/kean/Get), a web API client built using async/await with first-class Pulse integration

## Sponsors 💖

[Support](https://github.com/sponsors/kean) Pulse on GitHub Sponsors.

## About

`Pulse` is not just a tool, it's a framework. It records events from `URLSession` or from frameworks that use it, such as `Alamofire`, and displays them using `PulseUI` views that you integrate directly into your app. This way Pulse console is available for everyone who has your test builds. You or your QA team can view the logs on the device and easily share them to attach to bug reports.

> Pulse **is not** a network debugging proxy tool like Proxyman, Charles, or Wireshark. It *won't* automatically intercept all network traffic coming from your app or device.


## Getting Started

1. Add [`Pulse`](https://kean-docs.github.io/pulse/documentation/pulse/) framework into your app and enable [network logging](https://kean-docs.github.io/pulse/documentation/pulse/networklogging-article) to start collecting logs
2. Add [`PulseUI`](https://kean-docs.github.io/pulseui/documentation/pulseui/) framework into your app and show a `MainView` when you want to see the logs on the device
2. Download [Pulse Pro](https://github.com/kean/PulsePro) if you want to view logs shared from the device or view the device in real-time. To use remote logging, configure your app to use [local networking](https://developer.apple.com/documentation/bundleresources/information_property_list/nslocalnetworkusagedescription) and then enable remote logging from the PulseUI Settings tab.

## Documentation

Pulse is easy to learn and use:

- [Pulse Docs](https://kean-docs.github.io/pulse/documentation/pulse/) describe how to integrate the main framework and enable logging
- [PulseUI Docs](https://kean-docs.github.io/pulseui/documentation/pulseui/) contains information about adding the debug menu and console into your app
- [PulseLogHandler Docs](https://kean-docs.github.io/pulseloghandler/documentation/pulseloghandler/) describe how to use Pulse as [SwiftLog](https://github.com/apple/swift-log) backend

<a href="https://kean.blog/pulse/home">
<img src="https://user-images.githubusercontent.com/1567433/184552639-cf6765df-b5af-416b-95d3-0204e32df9d6.png">
</a>

## Pulse Pro

[**Pulse Pro**](https://kean.blog/pulse/pro) is a professional open-source macOS app that allows you to view logs in real-time. The app is designed to be flexible, expansive, and precise while using all the familiar macOS patterns. It makes it easy to navigate large log files with table and text modes, filters, scroller markers, an all-new network inspector, JSON filters, and more.

## Minimum Requirements

| Pulse      | Swift     | Xcode       | Platforms                                     |
|------------|-----------|-------------|-----------------------------------------------|
| Pulse 2.0  | Swift 5.6 | Xcode 13.3  | iOS 13.0, watchOS 7.0, tvOS 13.0, macOS 11.0  |
| Pulse 1.0  | Swift 5.3 | Xcode 12.0  | iOS 11.0, watchOS 6.0, tvOS 11.0, macOS 11.0  |

## License

Pulse is available under the MIT license. See the LICENSE file for more info.
