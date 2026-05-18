// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_aws_route53/otel_aws_route53.dart';
import 'package:test/test.dart';

void main() {
  group('otel_aws_route53', () {
    test('suppression toggles in zone', () async {
      expect(awsRoute53InstrumentationSuppressed(), isFalse);
      await runWithoutAwsRoute53InstrumentationAsync(() async {
        expect(awsRoute53InstrumentationSuppressed(), isTrue);
      });
      expect(awsRoute53InstrumentationSuppressed(), isFalse);
    });

    test('AwsRoute53Result fields default null', () {
      const r = AwsRoute53Result();
      expect(r.statusCode, isNull);
    });
  });
}
