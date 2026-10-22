// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_aws_route53/otel_aws_route53.dart';

/// Traces Aws Route53 calls with OpenTelemetry.
///
/// `otel_aws_route53` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Aws Route53 call in
/// [tracedAwsRoute53]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'aws-route53-example');

  // Traces a Aws Route53 call.
  final awsRoute53Id = await tracedAwsRoute53<String>(
    operation: 'create',
    invoke: () async {
      // Make the Aws Route53 call here, then report what it returned.
      const id = 'aws_route53_8f3a2c';
      return const AwsRoute53CallResult(
          value: id,
          result: AwsRoute53Result(
              hostedZoneId: 'hostedzone_8f3a2c',
              hostedZoneName: 'api.example.com',
              recordName: 'example',
              recordType: 'standard',
              ttl: 1,
              healthCheckId: 'healthcheck_8f3a2c',
              region: 'us-east-1',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedAwsRoute53 create returned $awsRoute53Id');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutAwsRoute53InstrumentationAsync.
  await runWithoutAwsRoute53InstrumentationAsync(
    () => tracedAwsRoute53<String>(
      operation: 'create',
      invoke: () async {
        const id = 'aws_route53_8f3a2c';
        return const AwsRoute53CallResult(
            value: id,
            result: AwsRoute53Result(
                hostedZoneId: 'hostedzone_8f3a2c',
                hostedZoneName: 'api.example.com',
                recordName: 'example',
                recordType: 'standard',
                ttl: 1,
                healthCheckId: 'healthcheck_8f3a2c',
                region: 'us-east-1',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
