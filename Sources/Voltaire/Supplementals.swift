import Cocoa

enum IME {
  static func isDarkMode() -> Bool { true }
}

enum InputMode {
  case imeModeCHS
  case imeModeCHT
  case imeModeNULL
}

enum ctlInputMethod {
  public enum currentKeyHandler {
    public static var inputMode = InputMode.imeModeCHT
  }
}

enum clsSFX {
  static func beep() {
    NSSound.beep()
  }
}

enum mgrPrefs {
  static let showPageButtonsInCandidateWindow = true
}
