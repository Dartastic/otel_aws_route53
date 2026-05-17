# otel_aws_route53

Dartastic OpenTelemetry bridge for AWS Route 53 (DNS + domain registration + health checks).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_aws_route53/otel_aws_route53.dart';

await tracedAwsRoute53<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return AwsRoute53CallResult(value: r, result: AwsRoute53Result(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutAwsRoute53InstrumentationAsync(() async {
  await client.someInternalSync();
});
```
