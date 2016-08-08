import 'package:test/test.dart';
import 'package:w_transport/w_transport_mock.dart';

import 'package:pact_consumer_dart/src/pact_mock_service_requests.dart';

main() {
  group('PactMockServiceRequests', () {
    String baseUrl = 'http://localhost:1234';

    group('getVerification', () {
      var fut; // Function Under Test

      setUp(() {
        Uri uri = Uri.parse(baseUrl + '/interactions/verification');
        fut = PactMockServiceRequests.getVerification;

        MockTransports.reset();

        MockResponse mockRes = new MockResponse.ok(body: '[]');

        MockTransports.http.expect('GET', uri, respondWith: mockRes);
      });

      group('when called with valid params', () {
        test('should return a Response', () async {
          var res = await fut(baseUrl);
          expect(res, new isInstanceOf<MockResponse>());
          expect(res.status, equals(200));
        });
      });

      tearDown(() {
        MockTransports.verifyNoOutstandingExceptions();
      });
    });

    group('putInteraction', () {
      var fut; // Function Under Test

      setUp(() {
        Uri uri = Uri.parse(baseUrl + '/interactions');
        fut = PactMockServiceRequests.putInteractions;

        MockTransports.reset();

        MockResponse mockRes = new MockResponse.ok(body: '[]');

        MockTransports.http.expect('PUT', uri, respondWith: mockRes);
      });

      group('when called with valid params', () {
        test('should return a Response', () async {
          var res = await fut([], baseUrl);
          expect(res, new isInstanceOf<MockResponse>());
          expect(res.status, equals(200));
        });
      });

      tearDown(() {
        MockTransports.verifyNoOutstandingExceptions();
      });
    });

    group('deleteInteractions', () {
      var fut; // Function Under Test

      setUp(() {
        Uri uri = Uri.parse(baseUrl + '/interactions');
        fut = PactMockServiceRequests.deleteInteractions;

        MockTransports.reset();

        MockResponse mockRes = new MockResponse.ok(body: '[]');

        MockTransports.http.expect('DELETE', uri, respondWith: mockRes);
      });

      group('when called with valid params', () {
        test('should return a Response', () async {
          var res = await fut(baseUrl);
          expect(res, new isInstanceOf<MockResponse>());
          expect(res.status, equals(200));
        });
      });

      tearDown(() {
        MockTransports.verifyNoOutstandingExceptions();
      });
    });

    group('postInteractions', () {
      var fut; // Function Under Test

      setUp(() {
        Uri uri = Uri.parse(baseUrl + '/interactions');
        fut = PactMockServiceRequests.postInteractions;

        MockTransports.reset();

        MockResponse mockRes = new MockResponse.ok(body: '[]');

        MockTransports.http.expect('POST', uri, respondWith: mockRes);
      });

      group('when called with valid params', () {
        test('should return a Response', () async {
          var res = await fut({}, baseUrl);
          expect(res, new isInstanceOf<MockResponse>());
          expect(res.status, equals(200));
        });
      });

      tearDown(() {
        MockTransports.verifyNoOutstandingExceptions();
      });
    });

    group('postPact', () {
      var fut; // Function Under Test

      setUp(() {
        Uri uri = Uri.parse(baseUrl + '/pact');
        fut = PactMockServiceRequests.postPact;

        MockTransports.reset();

        MockResponse mockRes = new MockResponse.ok(body: '[]');

        MockTransports.http.expect('POST', uri, respondWith: mockRes);
      });

      group('when called with valid params', () {
        test('should return a Response', () async {
          var res = await fut({}, baseUrl);
          expect(res, new isInstanceOf<MockResponse>());
          expect(res.status, equals(200));
        });
      });

      tearDown(() {
        MockTransports.verifyNoOutstandingExceptions();
      });
    });

    group('deleteSession', () {
      var fut; // Function Under Test

      setUp(() {
        Uri uri = Uri.parse(baseUrl + '/session');
        fut = PactMockServiceRequests.deleteSession;

        MockTransports.reset();

        MockResponse mockRes = new MockResponse.ok(body: '[]');

        MockTransports.http.expect('DELETE', uri, respondWith: mockRes);
      });

      group('when called with valid params', () {
        test('should return a Response', () async {
          var res = await fut(baseUrl);
          expect(res, new isInstanceOf<MockResponse>());
          expect(res.status, equals(200));
        });
      });

      tearDown(() {
        MockTransports.verifyNoOutstandingExceptions();
      });
    });
  });
}
