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

@TestOn('vm')
import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/vm.dart';
import 'package:pact_consumer_dart/pact_consumer_dart.dart';

main() {
  group('PactConsumerDart', () {
    group('when configured properly and an interaction is defined', () {
      PactMockService mockService;

      setUpAll(() async {
        configureWTransportForVM();
        mockService =
            new PactMockService('PactConsumerDart', 'PactMockService', dir : '~/pacts');

        // ensure Pact service is purged of interactions
        await mockService.resetSession();

        // define an interaction
        mockService.given('a request', providerState: 'an interaction').when(
            'GET', '/resource', headers: {
          'Accept': 'application/json'
        }).then(200,
            headers: {'Content-Type': 'application/json'},
            body: {'resource': 'coal'});
      });

      group('calling resetSession', () {
        test('then the Pact service is purged of interactions', () async {
          expect(mockService.resetSession(), completes);
        });
      });

      group('calling setup', () {
        test('then the interaction is successfully posted to the Pact service',
            () async {
          expect(mockService.setup(), completes);
        });
      });

      tearDownAll(() async {
        await mockService.resetSession();
      });
    });

    group(
        'when a request is made and the interaction has been successfully setup',
        () {
      PactMockService mockService;
      var responseBody;

      setUp(() async {
        configureWTransportForVM();
        mockService =
            new PactMockService('PactConsumerDart', 'PactMockService', dir : '~/pacts');

        // ensure Pact service is purged of interactions
        await mockService.resetSession();

        responseBody = {'resource': 'coal'};

        // define an interaction
        mockService
            .given('a request for coal',
                providerState: 'the resource coal exists')
            .when('GET', '/resource/coal', headers: {
          'Accept': 'application/json'
        }).then(200,
                headers: {'Content-Type': 'application/json'},
                body: responseBody);

        // setup the interaction
        await mockService.setup();
      });

      test('then Pact service sends the response defined in the interaction',
          () async {
        var res = await Http.get(
            Uri.parse('http://localhost:1234/resource/coal'),
            headers: {'Accept': 'application/json'});
        expect(res.status, equals(200));
        expect(res.body.asJson(), equals(responseBody));
        expect(res.body.asJson().keys, equals(responseBody.keys));
      });

      tearDown(() async {
        await mockService.resetSession();
      });
    });

    group(
        'when calling verifyAndWrite after a request has been successfully returned from the Pact service',
        () {
      PactMockService mockService;
      var responseBody;

      setUp(() async {
        configureWTransportForVM();
        mockService =
            new PactMockService('PactConsumerDart', 'PactMockService', dir : '~/pacts');

        // ensure Pact service is purged of interactions
        await mockService.resetSession();

        responseBody = {'resource': 'coal'};

        // define an interaction
        mockService
            .given('a request for coal',
                providerState: 'the resource coal exists')
            .when('GET', '/resource/coal', headers: {
          'Accept': 'application/json'
        }).then(200,
                headers: {'Content-Type': 'application/json'},
                body: responseBody);

        // setup the interaction
        await mockService.setup();

        // send a request like the one defined in the interaction
        await Http.get(Uri.parse('http://localhost:1234/resource/coal'),
            headers: {'Accept': 'application/json'});
      });

      test('then Pact will verify the interaction and write a Pact file',
          () async {
        expect(mockService.verifyAndWrite(), completes);
      });

      tearDown(() async {
        await mockService.resetSession();
      });
    });
  });
}
