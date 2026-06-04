// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_aws_route53_suppression.dart';

class AwsRoute53Result {
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

class AwsRoute53CallResult<T> {
  const AwsRoute53CallResult({required this.value, this.result});
  final T value;
  final AwsRoute53Result? result;
}

Future<T> tracedAwsRoute53<T>({
  required String operation,
  required Future<AwsRoute53CallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (awsRoute53InstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_aws_route53');
  final span = t.startSpan('route53 $operation', kind: SpanKind.client);
  try {
    span.addAttributes(
        OTel.attributes([OTel.attributeString('rpc.system', 'aws-api')]));
    span.addAttributes(
        OTel.attributes([OTel.attributeString('rpc.service', 'Route53')]));
    span.addAttributes(
        OTel.attributes([OTel.attributeString('dns.system', 'route53')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.hostedZoneId != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString('aws.route53.hosted_zone.id', res.hostedZoneId!)
        ]));
      }
      if (res.hostedZoneName != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('dns.zone', res.hostedZoneName!)]));
      }
      if (res.recordName != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('dns.name', res.recordName!)]));
      }
      if (res.recordType != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('dns.record.type', res.recordType!)]));
      }
      if (res.ttl != null) {
        span.addAttributes(
            OTel.attributes([OTel.attributeInt('dns.ttl', res.ttl!)]));
      }
      if (res.healthCheckId != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
              'aws.route53.health_check.id', res.healthCheckId!)
        ]));
      }
      if (res.region != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('cloud.region', res.region!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('http.response.status_code', res.statusCode!)]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('route53.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
              ErrorResource.errorType.key, res.errorCode ?? 'route53.error')
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
