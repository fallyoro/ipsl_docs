import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:ipsl_docs/core/constant.dart';

void logInfo(String message) {
  print('\x1B[32m$message\x1B[0m'); // Vert
}

void logError(String message) {
  print('\x1B[31m$message\x1B[0m'); // Rouge
}

void logWarning(String message) {
  print('\x1B[33m$message\x1B[0m'); // Jaune
}

Future<bool> isConnectedToInternet() async {
  final List<ConnectivityResult> connectivityResult =
      await (Connectivity().checkConnectivity());

  if (connectivityResult.contains(ConnectivityResult.mobile)) {
    return true;
  } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
    return true;
  } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
    return true;
  }
  return false;
}

void showNoConnectionMessage(BuildContext context) {
  final snackBar = SnackBar(
    content: Text(
      "Veuillez vous connecter à Internet",
      style: const TextStyle(color: Colors.white),
    ),
    backgroundColor: AppColors.darkSecondarySystemBackground,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

