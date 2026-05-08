/// Parses the user-typed string from the address bar.
///
/// Algorithm:
///   1. Trim leading / trailing whitespace; reject empty input.
///   2. Reject any input that still contains internal whitespace — a real
///      URL never does, so this is the unambiguous "garbage" signal.
///   3. `Uri.tryParse(input)` — if it has a non-empty scheme, accept.
///   4. Otherwise (bare host like `example.com`), retry with `https://`
///      prepended. Reject the retry only if the result has an empty host.
///
/// Returns `null` to signal "not a usable URL" — the caller (the address
/// bar) flashes a SnackBar and leaves cubit state unchanged.
Uri? parseAddressBarInput(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;

  // Internal whitespace is never a real URL.
  if (RegExp(r'\s').hasMatch(trimmed)) return null;

  final first = Uri.tryParse(trimmed);
  if (first == null) return null;

  // Accept anything that already has a scheme (https://, http://, about:, …).
  if (first.hasScheme) return first;

  // Bare host / scheme-less input — retry with explicit https://.
  final retry = Uri.tryParse('https://$trimmed');
  if (retry == null || retry.host.isEmpty) return null;
  return retry;
}
