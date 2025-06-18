


void logInfo(String message) {
  print('\x1B[32m$message\x1B[0m'); // Vert
}

void logError(String message) {
  print('\x1B[31m$message\x1B[0m'); // Rouge
}

void logWarning(String message) {
  print('\x1B[33m$message\x1B[0m'); // Jaune
}