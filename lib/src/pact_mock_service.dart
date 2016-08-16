import 'dart:async';
import 'package:w_transport/w_transport.dart';

import 'package:pact_consumer_dart/src/pact_interaction.dart';
import 'package:pact_consumer_dart/src/pact_mock_service_requests.dart';

class PactMockService {
  String _host;
  String _baseUrl;
  List<PactInteraction> _interactions;
  Map _pactDetails;

  /// Constructs an instance of PactMockService
  ///
  /// throws [StateError] if [port] is not supplied in the [opts] Map
  ///
  PactMockService(Map opts) {
    // throw StateError if `opts` doesn't include `port`
    if (opts['port'] == null) {
      throw new StateError(
          'creating PackMockService. Options did not include `port` which is required.');
    }

    _interactions = [];
    _host = (opts['host'] == null) ? '127.0.0.1' : opts['host'];
    _baseUrl = 'http://' + _host + ':' + opts['port'];
    _pactDetails = {
      'consumer': {'name': opts['consumer']},
      'provider': {'name': opts['provider']},
      'pact_dir': (opts['dir'] != null) ? opts['dir'] : 'pacts'
    };
  }

  // public methods

  Future resetSession() async {
    // Purge the session
    // throw the error if it occurs
    Response res = await PactMockServiceRequests.deleteSession(_baseUrl);

    if (res.status != 200) {
      throw new Exception(res.statusText);
    }
  }

  PactInteraction given(String providerState, String description) {
    if (providerState.isEmpty) {
      throw new StateError(
          'while creating PactInteraction, `providerState` cannot be an empty String.');
    }

    if (description.isEmpty) {
      throw new StateError(
          'while creating PactInteraction, `description` cannot be an empty String.');
    }

    PactInteraction interaction =
        (new PactInteraction()).given(providerState, description);
    _interactions.add(interaction);
    return interaction;
  }

  Future setup() async {
    // PUT the new interactions
    if (_interactions.isEmpty) {
      throw new StateError(
          'while setting up interactions, no interactions staged!');
    }

    for (PactInteraction interaction in _interactions) {
      Response res = await PactMockServiceRequests.postInteraction(
          interaction.toMap(), _baseUrl);

      if (res.status != 200) {
        throw new StateError(res.statusText);
      }
    }
    _interactions.clear();

    return this;
  }

  Future verifyAndWrite() async {
    Response verify =
        await await PactMockServiceRequests.getVerification(_baseUrl);

    if (verify.status != 200) {
      throw new Exception(verify.statusText);
    }

    Response write =
        await PactMockServiceRequests.postPact(_pactDetails, _baseUrl);

    if (write.status != 200) {
      throw new Exception(write.statusText);
    }
  }
}
