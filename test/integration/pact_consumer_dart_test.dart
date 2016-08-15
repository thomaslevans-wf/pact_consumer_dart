@TestOn('vm')
import 'dart:io';
import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_vm.dart';
import 'package:pact_consumer_dart/pact_consumer_dart.dart';

main() {
  group('PactConsumerDart', () {
    group('when configured properly and an interaction is defined', () {
      PactMockService mockService;

      setUpAll(() async {
        configureWTransportForVM();
        mockService = new PactMockService({
          'consumer': 'PactConsumerDart',
          'provider': 'pact-mock-service',
          'host': 'localhost',
          'port': '1234'
        });

        // ensure Pact service is purged of interactions
        await mockService.resetSession();

        // define an interaction
        mockService.given('an interaction', 'a request').when(
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
        mockService = new PactMockService({
          'consumer': 'PactConsumerDart',
          'provider': 'pact-mock-service',
          'host': 'localhost',
          'port': '1234'
        });

        // ensure Pact service is purged of interactions
        await mockService.resetSession();

        responseBody = {'resource': 'coal'};

        // define an interaction
        mockService
            .given('the resource coal exists', 'a request for coal')
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
        mockService = new PactMockService({
          'consumer': 'PactConsumerDart',
          'provider': 'pact-mock-service',
          'host': 'localhost',
          'port': '1234'
        });

        // ensure Pact service is purged of interactions
        await mockService.resetSession();

        responseBody = {'resource': 'coal'};

        // define an interaction
        mockService
            .given('the resource coal exists', 'a request for coal')
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
        mockService.verifyAndWrite().then((val) {
          var pactDetails =
              new File('/pacts/pactconsumerdart-pact-mock-service.json')
                  .readAsStringSync();
          expect(pactDetails, isNotEmpty);
        });
      });

      tearDown(() async {
        await mockService.resetSession();
      });
    });
  });
}
