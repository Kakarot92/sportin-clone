import 'package:firebase_auth/firebase_auth.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

/// Maps a Firebase auth error to a safe, localized message.
String authErrorMessage(AppLocalizations l10n, Object? error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'email-already-in-use':
        return l10n.errorEmailInUse;
      case 'invalid-email':
        return l10n.errorInvalidEmail;
      case 'weak-password':
        return l10n.errorWeakPassword;
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return l10n.errorWrongCredentials;
      case 'too-many-requests':
        return l10n.errorTooManyRequests;
      case 'network-request-failed':
        return l10n.errorNetwork;
      default:
        return l10n.errorGeneric;
    }
  }
  return l10n.errorGeneric;
}

bool isValidEmail(String? value) {
  if (value == null) return false;
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
}
