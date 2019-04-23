// Copyright 2015 Workiva Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:test/test.dart';

import 'package:pact_consumer_dart/src/pact_interaction.dart';

main() {
  group('PactInteraction', () {
    group('given', () {
      PactInteraction interaction;

      setUp(() {
        interaction = new PactInteraction();
      });

      group('when invoked with the optional param providerState', () {
        test('should use the provider state passed', () {
          var expected = 'state';
          var map = interaction
              .given('some interaction', providerState: expected)
              .toMap();
          expect(map['provider_state'], equals(expected));
        });
      });

      group('when invoked with an empty description', () {
        test('should throw StateError', () {
          var callGiven = () {
            interaction.given('');
          };

          expect(callGiven, throwsStateError);
        });
      });
    });

    group('when', () {
      PactInteraction interaction;

      group('when called with method, path, headers, and body', () {
        setUp(() {
          interaction = new PactInteraction();
        });

        test('should return the interaction with a fully formed request', () {
          var method = 'POST';
          var path = '/resources';
          var headers = {'Content-Type': 'application/json'};
          var body = {'resourceKey': 'resourceValue'};
          var match =
              interaction.when(method, path, headers: headers, body: body);

          expect(match.request, isNotNull);
          expect(match.request['method'], equals(method));
          expect(match.request['path'], equals(path));
          expect(
              match.request['headers'].toString(), equals(headers.toString()));
          expect(match.request['body'].toString(), equals(body.toString()));
        });
      });

      group('when called with a method and path', () {
        setUp(() {
          interaction = new PactInteraction();
        });

        test('should return the instance of PactInteraction', () {
          var match = interaction.when('GET', 'a/path');

          expect(match, const TypeMatcher<PactInteraction>());
        });
      });

      group('when `method` is an empty String', () {
        setUp(() {
          interaction = new PactInteraction();
        });

        test('should throw a StateError', () {
          var callWithRequest = () {
            interaction.when('', 'a/path');
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
            interaction.when('GET', '');
          };

          expect(callWithRequest, throwsStateError);
        });
      });
    });

    group('then', () {
      PactInteraction interaction;

      group('when called with `headers` and `body` params', () {
        setUp(() {
          interaction = new PactInteraction();
        });

        test('should return the instance of PactInteraction', () {
          var headers = {'Content-Type': 'application/json'};
          var body = {'someKey': 'someValue'};
          var match = interaction.then(200, headers: headers, body: body);

          expect(match, const TypeMatcher<PactInteraction>());
        });
      });
    });
  });
}
