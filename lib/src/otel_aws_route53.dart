// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_aws_route53_suppression.dart';

class AwsRoute53Result {
  /// Creates a result.
  const AwsRoute53Result({
    this.hostedZoneId,
    this.hostedZoneName,
    this.recordName,
    this.recordType,
    this.ttl,
    this.healthCheckId,
    this.region,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? hostedZoneId;
  final String? hostedZoneName;
  final String? recordName;
  final String? recordType;
  final int? ttl;
  final String? healthCheckId;
  final String? region;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class AwsRoute53CallResult<T> {
  /// Creates a call result.
  const AwsRoute53CallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final AwsRoute53Result? result;
}

Future<T> tracedAwsRoute53<T>({
  required String operation,
  required Future<AwsRoute53CallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (awsRoute53InstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_aws_route53');
  final span = t.startSpan('route53 $operation', kind: SpanKind.client);
  try {
    span.addAttributes(
        OTelAPI.attributes([OTelAPI.attributeString('rpc.system', 'aws-api')]));
    span.addAttributes(OTelAPI.attributes(
        [OTelAPI.attributeString('rpc.service', 'Route53')]));
    span.addAttributes(
        OTelAPI.attributes([OTelAPI.attributeString('dns.system', 'route53')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.hostedZoneId != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
              'aws.route53.hosted_zone.id', res.hostedZoneId!)
        ]));
      }
      if (res.hostedZoneName != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('dns.zone', res.hostedZoneName!)]));
      }
      if (res.recordName != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('dns.name', res.recordName!)]));
      }
      if (res.recordType != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('dns.record.type', res.recordType!)]));
      }
      if (res.ttl != null) {
        span.addAttributes(
            OTelAPI.attributes([OTelAPI.attributeInt('dns.ttl', res.ttl!)]));
      }
      if (res.healthCheckId != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
              'aws.route53.health_check.id', res.healthCheckId!)
        ]));
      }
      if (res.region != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('cloud.region', res.region!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('route53.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
              ErrorAttributes.errorType.key, res.errorCode ?? 'route53.error')
        ]));
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
