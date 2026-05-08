/// Default URL used when the user opens a new tab without typing one.
///
/// We avoid `about:blank` because rendering varies by platform in
/// `webview_flutter` 4.x — `https://example.com` is universally well-behaved.
final Uri kDefaultNewTabUrl = Uri.parse('https://example.com');
