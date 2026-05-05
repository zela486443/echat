class SecurityUtils {
  /// Simple hash for client-side PIN - matching the web app's logic exactly.
  static String hashPin(String pin) {
    int hash = 0;
    for (int i = 0; i < pin.length; i++) {
      int char = pin.codeUnitAt(i);
      // ((hash << 5) - hash) + char;
      // In Dart, we use .toSigned(32) to mimic the JS bitwise OR zero (|= 0) 
      // which forces 32-bit signed integer behavior.
      hash = (((hash << 5) - hash) + char).toSigned(32);
    }
    return hash.toRadixString(36);
  }
  
  /// Verifies if a raw PIN matches a stored hash.
  static bool verifyPin(String rawPin, String storedHash) {
    return hashPin(rawPin) == storedHash;
  }
}
