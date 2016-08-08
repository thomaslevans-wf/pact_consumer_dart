import 'dart:async';
import 'package:w_transport/w_transport.dart';

import 'package:pact_consumer_dart/src/pact_interaction.dart';
import 'package:pact_consumer_dart/src/pact_mock_service_requests.dart';

class PactMockService {
  String _host;
  String _baseUrl;
  List<Map> _interactions;
  Map _pactDetails;

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
      'provider': {'name': opts['provider']}
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

  PactInteraction given(String providerState) {
    if (providerState.isEmpty) {
      throw new StateError(
          'creating PactInteraction, `providerState` cannot be an empty String.');
    }

    PactInteraction interaction = (new PactInteraction()).given(providerState);
    _interactions.add(interaction.toMap());
    return interaction;
  }

  Future setup() async {
    // PUT the new interactions
    if (_interactions.isEmpty) {
      throw new StateError('setting up interactions, no interactions staged!');
    }

    var interactions = _interactions.toList();
    _interactions.clear();

    Response res =
        await PactMockServiceRequests.putInteractions(interactions, _baseUrl);

    if (res.status != 200) {
      throw new StateError(res.statusText);
    }

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
