// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

import Foundation

// swiftlint:disable file_length
// swiftlint:disable line_length

// swiftlint:disable type_body_length
enum L10n {
  /// TURN\nIT ON
  case buttonOffTitle
  /// TURN\nIT OFF
  case buttonOnTitle
  /// You're connected to this address
  case clientAddressExplanation
  /// QR code
  case displayQRCodeTitle
  /// Made with love by
  case madeBy
  /// Clipboard updated!
  case notificationTitle
  /// OR Scan QR code\non another device
  case promptToScan
  /// Scan this code in CLPBRD app running on\nanother device to get connected.
  case qrDescription
  /// Scan QR from CLPBRD app on other device
  case scanQRCodeTitle
  /// Connect to this address in your browser
  case serverAddressExplanation
  /// Send clipboard between your phone,\ndesktop or another phone.\n\nTurn service on and just copy and paste.
  case usageDescription
}
// swiftlint:enable type_body_length

extension L10n: CustomStringConvertible {
  var description: String { return self.string }

  var string: String {
    switch self {
      case .buttonOffTitle:
        return L10n.tr(key: "button_off_title")
      case .buttonOnTitle:
        return L10n.tr(key: "button_on_title")
      case .clientAddressExplanation:
        return L10n.tr(key: "client_address_explanation")
      case .displayQRCodeTitle:
        return L10n.tr(key: "display_QR_code_title")
      case .madeBy:
        return L10n.tr(key: "made_by")
      case .notificationTitle:
        return L10n.tr(key: "notification_title")
      case .promptToScan:
        return L10n.tr(key: "prompt_to_scan")
      case .qrDescription:
        return L10n.tr(key: "qr_description")
      case .scanQRCodeTitle:
        return L10n.tr(key: "scan_QR_code_title")
      case .serverAddressExplanation:
        return L10n.tr(key: "server_address_explanation")
      case .usageDescription:
        return L10n.tr(key: "usage_description")
    }
  }

  private static func tr(key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

func tr(_ key: L10n) -> String {
  return key.string
}

private final class BundleToken {}

