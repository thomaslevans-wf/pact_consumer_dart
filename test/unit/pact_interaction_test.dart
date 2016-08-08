import 'package:test/test.dart';

import 'package:pact_consumer_dart/src/pact_interaction.dart';

main() {
  group('PactInteraction', () {
    group('uponReceiving', () {
      PactInteraction interaction;

      group('when passed a valid String as `description`', () {
        setUp(() {
          interaction = new PactInteraction();
        });

        test(
            'should return the instance of PactInteraction with the description set',
            () {
          var match = interaction.uponReceiving('a description');

          expect(match, new isInstanceOf<PactInteraction>());
          expect(match, equals(interaction));
        });
      });

      group('when passed an invalid String as provider state', () {
        setUp(() {
          interaction = new PactInteraction();
        });

        test('should throw StateError', () {
          var callUponReceiving = () {
            interaction.uponReceiving('');
          };

          expect(callUponReceiving, throwsStateError);
        });
      });
    });

    group('withRequest', () {
      PactInteraction interaction;

      group('when called with method, path, headers, and body', () {
        setUp(() {
          interaction = new PactInteraction();
        });

        test('should return the interaction with a fully formed request', () {
          var method = 'POST';
          var path = '/resources';
          var opts = {
            'headers': {'Content-Type': 'application/json'},
            'body': {'resourceKey': 'resourceValue'}
          };
          var match = interaction.withRequest(method, path, opts: opts);

          expect(match.request, isNotNull);
          expect(match.request['method'], equals(method));
          expect(match.request['path'], equals(path));
          expect(match.request['headers'].toString(),
              equals(opts['headers'].toString()));
          expect(match.request['body'].toString(),
              equals(opts['body'].toString()));
        });
      });

      group('when called with a method and path', () {
        setUp(() {
          interaction = new PactInteraction();
        });

        test('should return the instance of PactInteraction', () {
          var match = interaction.withRequest('GET', 'a/path');

          expect(match, new isInstanceOf<PactInteraction>());
        });
      });

      group('when `method` is an empty String', () {
        setUp(() {
          interaction = new PactInteraction();
        });

        test('should throw a StateError', () {
          var callWithRequest = () {
            interaction.withRequest('', 'a/path');
          };

          expect(callWithRequest, throwsStateError);
        });
      });

      group('when `path` is an empty String', () {
        setUp(() {
          interaction = new PactInteraction();
        });

        test('should throw a StateError', () {
          var callWithRequest = () {
            interaction.withRequest('GET', '');
          };

          expect(callWithRequest, throwsStateError);
        });
      });
    });

    group('willRespondWith', () {
      PactInteraction interaction;

      group('when called with `headers` and `body` params', () {
        setUp(() {
          interaction = new PactInteraction();
        });

        test('should return the instance of PactInteraction', () {
          var headers = {'Content-Type': 'application/json'};
          var body = {'someKey': 'someValue'};
          var match =
              interaction.willRespondWith(200, headers: headers, body: body);

          expect(match, new isInstanceOf<PactInteraction>());
        });
      });
    });
  });
}
