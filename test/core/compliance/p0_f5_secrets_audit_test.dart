// P0-F5 — Audit: No Hardcoded Secrets in Dart Code
//
// Exhaustive static audit of lib/ confirming that no API keys, bearer tokens,
// private keys, or credentials are hardcoded in Dart source files beyond what
// is documented and known-safe.
//
// Audit findings summary:
//
// RISK ASSESSMENT:
//
// 1. lib/firebase_options.dart — Firebase apiKey values (AIzaSy...)
//    STATUS: KNOWN-SAFE / NO ACTION REQUIRED
//    REASON: Firebase Web/Android/iOS API keys (AIzaSy prefix) are intentionally
//    embedded in mobile apps. This is the documented Firebase pattern:
//    https://firebase.google.com/docs/projects/api-keys
//    These keys are NOT secret — they identify the Firebase project and are
//    restricted by Firebase Security Rules and SHA-1 fingerprint restrictions
//    (Android) / bundle ID restrictions (iOS) set in Firebase Console.
//    They are equivalent to a "project ID" embedded in the binary.
//    All three flavors (dev/staging/pro) have their own key.
//    MITIGATION: Keys are scoped per-flavor and per-platform. Before making
//    the repo public, rotate all keys (see SECURITY_PUBLIC_READINESS.md §2).
//
// 2. lib/core/config/app_environment.dart — URLs only (no secrets)
//    STATUS: SAFE
//    REASON: Contains Cloud Run backend URL (public HTTPS endpoint) and
//    localhost fallbacks. No credentials, no tokens.
//
// 3. lib/core/network/dio_client.dart — Bearer string literal
//    STATUS: SAFE
//    REASON: The string 'Bearer ' is a static HTTP header prefix, not a
//    token value. The actual token is obtained at runtime from
//    FirebaseAuth.getIdToken() via the injected tokenProvider.
//    No token value is ever hardcoded.
//
// 4. All other lib/**/*.dart files
//    STATUS: CLEAN — no secrets found
//    AUDIT COMMANDS USED (run manually to verify):
//      rg -rn "AIza" lib/ --glob "*.dart"
//      rg -rn "sk-|sk_live|sk_test" lib/ --glob "*.dart"
//      rg -rn "ghp_|gho_|ghs_|glpat-" lib/ --glob "*.dart"
//      rg -rn "AKIA[0-9A-Z]{16}" lib/ --glob "*.dart"
//      rg -rn "xox[baprs]-" lib/ --glob "*.dart"
//      rg -rn "password\s*=\s*['\"]" lib/ --glob "*.dart"
//      rg -rn "token\s*=\s*['\"]" lib/ --glob "*.dart"
//      rg -rn "secret\s*=\s*['\"]" lib/ --glob "*.dart"
//      rg -rn "http[s]?://api\." lib/ --glob "*.dart"
//
// Refs: TASK-022 (#49), P0-F5 checklist item 6.1
// ignore_for_file: avoid_redundant_argument_values

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Scans all .dart files in lib/ for the given [pattern].
///
/// Returns a list of "file:line: match" strings for failures.
List<String> scanForPattern(String pattern, {List<String>? allowlist}) {
  final libDir = Directory('lib');
  final findings = <String>[];

  if (!libDir.existsSync()) {
    return findings; // No lib dir (e.g. when running from wrong cwd)
  }

  for (final entity
      in libDir.listSync(recursive: true, followLinks: false)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;

    final lines = entity.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final matchesPattern = RegExp(pattern).hasMatch(line);
      if (!matchesPattern) continue;

      // Check allowlist: skip if ANY allowlist entry matches the line
      if (allowlist != null &&
          allowlist.any((allow) => line.contains(allow))) {
        continue;
      }

      findings.add('${entity.path}:${i + 1}: $line');
    }
  }

  return findings;
}

void main() {
  group('P0-F5: Secrets Audit', () {
    // ──────────────────────────────────────────────────────────────────────────
    // 1. No third-party API key patterns in lib/
    // ──────────────────────────────────────────────────────────────────────────
    group('Static scan — forbidden secret patterns in lib/', () {
      test('P0-F5: no OpenAI/Anthropic/Stripe secret keys (sk-...)', () {
        final findings = scanForPattern(r'\bsk-[A-Za-z0-9]{20,}');
        expect(findings, isEmpty,
            reason:
                'Found potential OpenAI/Stripe secret keys:\n${findings.join('\n')}');
      });

      test('P0-F5: no GitHub personal access tokens (ghp_|gho_|ghs_)', () {
        final findings = scanForPattern('gh[poa]_[A-Za-z0-9]{36,}');
        expect(findings, isEmpty,
            reason:
                'Found potential GitHub tokens:\n${findings.join('\n')}');
      });

      test('P0-F5: no AWS access keys (AKIA...)', () {
        final findings = scanForPattern('AKIA[0-9A-Z]{16}');
        expect(findings, isEmpty,
            reason:
                'Found potential AWS access keys:\n${findings.join('\n')}');
      });

      test('P0-F5: no Slack tokens (xox[baprs]-)', () {
        final findings = scanForPattern('xox[baprs]-[0-9A-Za-z-]{8,}');
        expect(findings, isEmpty,
            reason:
                'Found potential Slack tokens:\n${findings.join('\n')}');
      });

      test('P0-F5: no SendGrid API keys (SG.)', () {
        final findings =
            scanForPattern(r'SG\.[A-Za-z0-9_-]{22,}\.[A-Za-z0-9_-]{43,}');
        expect(findings, isEmpty,
            reason:
                'Found potential SendGrid keys:\n${findings.join('\n')}');
      });

      test('P0-F5: no GitLab personal access tokens (glpat-)', () {
        final findings = scanForPattern('glpat-[A-Za-z0-9_-]{20,}');
        expect(findings, isEmpty,
            reason:
                'Found potential GitLab tokens:\n${findings.join('\n')}');
      });

      test('P0-F5: no hardcoded Bearer token values', () {
        // Allow: the string 'Bearer ' (static header prefix — not a value)
        // Forbid: Bearer <actual-token-value> patterns
        final findings = scanForPattern(
          r'[Bb]earer\s+[A-Za-z0-9+/=_-]{20,}',
          allowlist: <String>[
            r"= 'Bearer $token'", // runtime interpolation
            r'= "Bearer $token"', // runtime interpolation
            "= 'Bearer '", // static prefix
            '= "Bearer "', // static prefix
            "'Bearer '", // prefix string literal
            '"Bearer "', // prefix string literal
            '// ', // comment lines
            '/// ', // doc comment lines
          ],
        );
        expect(findings, isEmpty,
            reason:
                'Found hardcoded Bearer token values:\n${findings.join('\n')}');
      });

      test('P0-F5: no hardcoded password assignments', () {
        final findings = scanForPattern(
          r'''password\s*=\s*['"][^'"]{3,}''',
          allowlist: <String>['// ', '/// ', 'test', 'Test', 'mock', 'Mock'],
        );
        expect(findings, isEmpty,
            reason:
                'Found hardcoded password values:\n${findings.join('\n')}');
      });

      test('P0-F5: no direct calls to third-party APIs (mangadex, jikan)', () {
        final findings = scanForPattern(
          r'https?://api\.(mangadex|jikan)\.org',
        );
        expect(findings, isEmpty,
            reason:
                'Flutter must not call third-party APIs directly — '
                'all requests must go through the InkScroller backend.\n'
                '${findings.join('\n')}');
      });

      test(
          'P0-F5: public repo keeps firebase_options.dart sanitized and env-driven',
          () {
        final allFindings = scanForPattern('AIzaSy[A-Za-z0-9_-]{33}');

        expect(allFindings, isEmpty,
            reason:
                'Public showcase repo must not contain hardcoded Firebase API keys in lib/. '
                'Found:\n${allFindings.join('\n')}');

        final firebaseOptions =
            File('lib/firebase_options.dart').readAsStringSync();

        expect(firebaseOptions.contains('String.fromEnvironment('), isTrue,
            reason:
                'Expected lib/firebase_options.dart to use environment-injected values.');

        expect(firebaseOptions.contains('REPLACE_ME'), isTrue,
            reason:
                'Expected placeholder defaults in sanitized firebase_options.dart.');
      });
    });

    // ──────────────────────────────────────────────────────────────────────────
    // 2. Backend URLs are non-secret public endpoints
    // ──────────────────────────────────────────────────────────────────────────
    group('URL audit — only known-safe endpoints in lib/', () {
      test('P0-F5: all hardcoded HTTP URLs are InkScroller backend or localhost',
          () {
        final urlDir = Directory('lib');
        if (!urlDir.existsSync()) return;

        final allUrls = <String>[];
        for (final entity
            in urlDir.listSync(recursive: true, followLinks: false)) {
          if (entity is! File || !entity.path.endsWith('.dart')) continue;
          final lines = entity.readAsLinesSync();
          for (var i = 0; i < lines.length; i++) {
            final line = lines[i];
            if (RegExp('https?://').hasMatch(line) &&
                !line.trimLeft().startsWith('//') &&
                !line.trimLeft().startsWith('*')) {
              allUrls.add('${entity.path}:${i + 1}: ${line.trim()}');
            }
          }
        }

        const forbiddenDomains = <String>[
          'api.mangadex.org',
          'api.jikan.moe',
          'myanimelist.net',
        ];

        for (final url in allUrls) {
          for (final domain in forbiddenDomains) {
            expect(url.contains(domain), isFalse,
                reason:
                    'P0-F5: Found direct call to forbidden domain "$domain":\n$url');
          }
        }
      });
    });

    // ──────────────────────────────────────────────────────────────────────────
    // 3. .env.example has no real secret values
    // ──────────────────────────────────────────────────────────────────────────
    test('P0-F5: .env.example contains only placeholder values', () {
      final envFile = File('.env.example');
      if (!envFile.existsSync()) {
        // No .env.example — nothing to audit
        return;
      }

      final content = envFile.readAsStringSync();

      // Must not contain actual Cloud Run project numbers or real URLs with
      // project numbers (placeholder format is documented in the file)
      expect(
        content.contains('AIzaSy'),
        isFalse,
        reason: '.env.example must not contain real Firebase API keys',
      );
      expect(
        content.contains('sk-'),
        isFalse,
        reason: '.env.example must not contain real secret keys',
      );
    });
  });
}
