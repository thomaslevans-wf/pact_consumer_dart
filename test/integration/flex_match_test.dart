@TestOn('vm')
import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/vm.dart';
import 'package:pact_consumer_dart/pact_consumer_dart.dart';

main() {
  group('PactConsumerDart', () {
    group('when using Flex Match', () {
      PactMockService mockService;

      setUpAll(() async {
        configureWTransportForVM();
        mockService =
            new PactMockService('PactConsumerDart', 'PactMockService', dir: '~/pacts');

        // ensure Pact service is purged of interactions
        await mockService.resetSession();

        // interaction for `somethingLike` used in response
        mockService
            .given('request for Mary the alligator',
                providerState: 'there is an alligator named Mary')
            .when('GET', '/alligators/Mary')
            .then(200,
                body: FlexMatch.somethingLike({'name': 'Mary', 'age': 73}));

        // interaction for `somethingLike` used in request
        mockService
            .given('a request to update an alligator',
                providerState: 'an alligator named Marry exists')
            .when('POST', '/alligators/Mary', headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=utf-8'
        }, body: {
          'age': FlexMatch.somethingLike(10)
        }).then(200,
                headers: {'Content-Type': 'application/json'},
                body: {'age': 10});

        // interaction for `eachLike` used in response
        mockService
            .given('the employee Jim exists',
                providerState: 'a request for the employee Jim')
            .when('GET', '/employees/Jim')
            .then(200, headers: {
          'Content-Type': 'application/json'
        }, body: {
          'name': 'Jim',
          'dependants': FlexMatch.eachLike({'name': 'Fred', 'age': 2})
        });

        // interaction for `eachLike` used in request
        mockService
            .given('a request to create an employee',
                providerState: 'there is a route /employees')
            .when('POST', '/employees', headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=utf-8'
        }, body: {
          'name': 'Jim',
          'dependants': FlexMatch.eachLike({
            'name': FlexMatch.term('Lisa', '\\D+'),
            'age': FlexMatch.somethingLike(10)
          })
        }).then(201, headers: {
          'Content-Type': 'application/json'
        }, body: {
          'name': 'Jim',
          'dependants': [
            {'name': 'James', 'age': 17},
            {'name': 'Laura', 'age': 12}
          ]
        });

        // interaction for `term`
        mockService
            .given('request for products', providerState: 'there is a product')
            .when('GET', '/products', query: {
          'category': FlexMatch.term('pizza', '\\D+')
        }).then(200, body: {
          'collections': [
            {'guid': FlexMatch.term('1111222233334444', '\\d{16}')}
          ]
        });

        await mockService.setup();
      });

      group('eachLike', () {
        group(
            'when used in the interaction request and values do not pass the FlexMatch',
            () {
          test('should not handle the request', () async {
            Uri uri = Uri.parse('http://localhost:1234/employees');
            var headers = {'Accept': 'application/json'};
            var body = {
              'name': 'Jim',
              'dependants': {'name': 'Daren', 'age': 21}
            };
            JsonRequest req = new JsonRequest()
              ..uri = uri
              ..headers = headers
              ..body = body;

            expect(req.post(), throwsException);
          });
        });

        group(
            'when used in the interaction request in conjunction with `term` and `somethingLike` and a matching request is received',
            () {
          test('should handle the request', () async {
            Uri uri = Uri.parse('http://localhost:1234/employees');
            var headers = {'Accept': 'application/json'};
            var body = {
              'name': 'Jim',
              'dependants': [
                {'name': 'Daren', 'age': 21},
                {'name': 'Sally', 'age': 18},
                {'name': 'Carl', 'age': 12}
              ]
            };
            JsonRequest req = new JsonRequest()
              ..uri = uri
              ..headers = headers
              ..body = body;
            var res = await req.post();

            expect(res.status, equals(201));
            var bodyMap = res.body.asJson();
            expect(bodyMap.containsKey('name'), isTrue);
            expect(bodyMap['name'], equals('Jim'));
          });
        });

        group('when used in the interaction response', () {
          test('should send a response with the oracle values', () async {
            var res = await Http
                .get(Uri.parse('http://localhost:1234/employees/Jim'));

            expect(res.status, equals(200));

            Map bodyMap = res.body.asJson();

            expect(bodyMap.containsKey('name'), isTrue);
            expect(bodyMap['name'], equals('Jim'));
            expect(bodyMap.containsKey('dependants'), isTrue);
            expect(bodyMap['dependants'].length, equals(1));
          });
        });
      });

      group('somethingLike', () {
        group('when used in the interaction response', () {
          test('should send a response with the oracle values', () async {
            var res = await Http
                .get(Uri.parse('http://localhost:1234/alligators/Mary'));

            expect(res.status, equals(200));

            Map bodyMap = res.body.asJson();

            expect(bodyMap.containsKey('name'), isTrue);
            expect(bodyMap['name'], equals('Mary'));
            expect(bodyMap.containsKey('age'), isTrue);
            expect(bodyMap['age'], equals(73));
          });
        });

        group('when used in the interaction request', () {
          test('should not accept a value of a different type', () async {
            Uri uri = Uri.parse('http://localhost:1234/alligators/Mary');
            var headers = {'Accept': 'application/json'};
            var body = {'age': 'fifteen'};
            JsonRequest req = new JsonRequest()
              ..uri = uri
              ..headers = headers
              ..body = body;
            expect(req.post(), throwsException);
          });

          test('should accept a value of the same type', () async {
            Uri uri = Uri.parse('http://localhost:1234/alligators/Mary');
            var headers = {'Accept': 'application/json'};
            var body = {'age': 15};
            JsonRequest req = new JsonRequest()
              ..uri = uri
              ..headers = headers
              ..body = body;
            var res = await req.post();

            expect(res.status, equals(200));
            var bodyMap = res.body.asJson();
            expect(bodyMap.containsKey('age'), isTrue);
            expect(bodyMap['age'], equals(10));
          });
        });
      });

      group('term', () {
        group('and the request made uses the oracle defined in `generate`', () {
          var res;

          setUpAll(() async {
            res = await Http.get(
                Uri.parse('http://localhost:1234/products?category=pizza'));
          });

          test('should handle the request', () {
            expect(res.status, equals(200));
          });

          test('should send a response with the oracle defined in `generate`',
              () {
            var responseMap = res.body.asJson();
            expect(responseMap.containsKey('collections'), isTrue);

            var product = responseMap['collections'].first;
            expect(product.containsKey('guid'), isTrue);
            expect(product['guid'], equals('1111222233334444'));
          });
        });

        group('and the request made uses a value that passes the FlexMatch',
            () {
          var res;

          setUpAll(() async {
            res = await Http.get(
                Uri.parse('http://localhost:1234/products?category=shoes'));
          });

          test('should handle the request', () {
            expect(res.status, equals(200));
          });

          test('should send a response with the oracle defined in `generate`',
              () {
            var bodyMap = res.body.asJson();
            expect(bodyMap.containsKey('collections'), isTrue);

            var product = bodyMap['collections'].first;
            expect(product.containsKey('guid'), isTrue);
            expect(product['guid'], equals('1111222233334444'));
          });
        });

        group(
            'and the request made uses a value that does not pass the FlexMatch',
            () {
          test('should not handle the request', () async {
            var uri = Uri.parse('http://localhost:1234/products?category=1');

            expect(Http.get(uri), throwsException);
          });
        });
      });

      tearDownAll(() {
        mockService.resetSession();
      });
    });
  });
}
