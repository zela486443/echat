import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class LinkPreview {
  final String url;
  final String? title;
  final String? description;
  final String? imageUrl;
  final String? siteName;
  LinkPreview({required this.url, this.title, this.description, this.imageUrl, this.siteName});
}

class LinkPreviewService {
  final Map<String, LinkPreview?> _cache = {};

  static final _urlRegex = RegExp(
    r'https?://[^\s/$.?#].[^\s]*',
    caseSensitive: false,
  );

  List<String> extractUrls(String text) =>
      _urlRegex.allMatches(text).map((m) => m.group(0)!).toList();

  Future<LinkPreview?> getLinkPreview(String url) async {
    if (_cache.containsKey(url)) return _cache[url];
    try {
      final res = await http.get(Uri.parse(url), headers: {'User-Agent': 'eChats/1.0'})
          .timeout(const Duration(seconds: 5));
      if (res.statusCode != 200) { _cache[url] = null; return null; }
      final body = res.body;
      final preview = LinkPreview(
        url: url,
        title:       _meta(body, 'og:title')       ?? _meta(body, 'twitter:title')       ?? _titleTag(body),
        description: _meta(body, 'og:description') ?? _meta(body, 'twitter:description'),
        imageUrl:    _meta(body, 'og:image')        ?? _meta(body, 'twitter:image'),
        siteName:    _meta(body, 'og:site_name'),
      );
      _cache[url] = preview;
      return preview;
    } catch (_) {
      _cache[url] = null;
      return null;
    }
  }

  void clearCache() => _cache.clear();

  String? _meta(String html, String property) {
    final patterns = [
      RegExp('property=["\']$property["\'][^>]*content=["\']([^"\']+)', caseSensitive: false),
      RegExp('content=["\']([^"\']+)["\'][^>]*property=["\']$property["\']', caseSensitive: false),
      RegExp('name=["\']$property["\'][^>]*content=["\']([^"\']+)', caseSensitive: false),
    ];
    for (final p in patterns) {
      final m = p.firstMatch(html);
      if (m != null) return m.group(1);
    }
    return null;
  }

  String? _titleTag(String html) {
    final m = RegExp(r'<title[^>]*>([^<]+)</title>', caseSensitive: false).firstMatch(html);
    return m?.group(1)?.trim();
  }
}

final linkPreviewServiceProvider = Provider<LinkPreviewService>((ref) => LinkPreviewService());
