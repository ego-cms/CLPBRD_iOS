// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

import Foundation

// swiftlint:disable file_length
// swiftlint:disable line_length

// swiftlint:disable type_body_length
enum L10n {
  /// This is not CLPBRD code
  case badQRCodeWarning
  /// TURN\nIT ON
  case buttonOffTitle
  /// TURN\nIT OFF
  case buttonOnTitle
  /// App needs access to the camera in\norder to scan QR codes.
  case cameraPermissionFailureDescription
  /// You're connected to this address
  case clientAddressExplanation
  /// QR code
  case displayQRCodeTitle
  /// Made with love by
  case madeBy
  /// Magic\nButton
  case magicButton
  /// Clipboard updated!
  case notificationTitle
  /// OR Scan QR code\non another device
  case promptToScan
  /// Scan this code in CLPBRD app running on\nanother device to get connected.
  case qrDescription
  /// Scanning QR code...
  case scanQRCodeTitle
  /// Connect to this address in your browser
  case serverAddressExplanation
  /// Enable access in Settings
  case settingsButtonTitle
  /// Send clipboard between your phone,\ndesktop or another phone.\n\nTurn service on and just copy and paste.
  case usageDescription
}
// swiftlint:enable type_body_length

extension L10n: CustomStringConvertible {
  var description: String { return self.string }

  var string: String {
    switch self {
      case .badQRCodeWarning:
        return L10n.tr(key: "bad_QR_code_warning")
      case .buttonOffTitle:
        return L10n.tr(key: "button_off_title")
      case .buttonOnTitle:
        return L10n.tr(key: "button_on_title")
      case .cameraPermissionFailureDescription:
        return L10n.tr(key: "camera_permission_failure_description")
      case .clientAddressExplanation:
        return L10n.tr(key: "client_address_explanation")
      case .displayQRCodeTitle:
        return L10n.tr(key: "display_QR_code_title")
      case .madeBy:
        return L10n.tr(key: "made_by")
      case .magicButton:
        return L10n.tr(key: "magic_button")
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
      case .settingsButtonTitle:
        return L10n.tr(key: "settings_button_title")
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

