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

import 'dart:async';
import 'package:w_transport/w_transport.dart';

import 'package:pact_consumer_dart/src/pact_interaction.dart';
import 'package:pact_consumer_dart/src/pact_mock_service_requests.dart';

/// Encapsulates the [PactMockService] client for communicating with the Pact Service.
class PactMockService {
  String _host;
  String _baseUrl;
  List<PactInteraction> _interactions;
  Map _pactDetails;

  /// Constructs an instance of [PactMockService]
  ///
  /// throws [StateError] if [port] is an empty String
  PactMockService(String consumer, String provider,
      {String port, String dir, String host}) {
    _interactions = [];
    _host = (host != null) ? host : '127.0.0.1';
    _baseUrl = (port != null) ? 'http://$_host:$port' : 'http://$_host:1234';
    _pactDetails = {
      'consumer': {'name': consumer},
      'provider': {'name': provider},
      'pact_dir': (dir != null) ? dir : 'pacts'
    };
  }

  /// Resets the current session by deleting any interactions that are in the Pact Service.
  ///
  /// Throws [Exception] if the response from the Pact Service is other than 200.
  Future resetSession() async {
    // Purge the session
    // throw the error if it occurs
    Response res = await PactMockServiceRequests.deleteSession(_baseUrl);

    if (res.status != 200) {
      throw new Exception(res.statusText);
    }
  }

  /// Returns a new instance of [PactInteraction] using the provided [providerState] and [description].
  ///
  /// Throws a [StateError] if [description] is an empty String.
  PactInteraction given(String description, {String providerState}) {
    if (description.isEmpty) {
      throw new StateError(
          'while creating PactInteraction, `description` cannot be an empty String.');
    }

    PactInteraction interaction = (new PactInteraction())
        .given(description, providerState: providerState);
    _interactions.add(interaction);
    return interaction;
  }

  /// Sets up any staged interactions by posting them to the Pact Service.
  ///
  /// Throws a [StateError] if the response from the Pact Service is other than 200.
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

  /// Verifies all interactions setup on the Pact Service have been exercised, then pending success writes the Pact file for the interactions.
  ///
  /// Throws [Exception] if the request for verification response status is other than 200.
  /// Throws [Exception] if the request to write the pact file response status is other than 200.
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
