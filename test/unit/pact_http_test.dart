import 'dart:async';
import 'package:test/test.dart';
import 'package:w_transport/w_transport_mock.dart';

import 'package:pact_consumer_dart/src/pact_http.dart';

main() {
  group('PactHttp', () {
    group('makeRequest', () {
      setUp(() {
        MockTransports.reset();

        MockResponse res = new MockResponse.ok(body: '[]');

        MockTransports.http.expect('GET', Uri.parse('http://www.google.com'),
            respondWith: res);
      });

      test('returns a Future', () {
        Uri uri = Uri.parse('http://www.google.com');
        expect(PactHttp.makeRequest('GET', uri), new isInstanceOf<Future>());
      });
    });
  });
}
