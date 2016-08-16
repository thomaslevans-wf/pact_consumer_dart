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

/// Represents an interaction between a Provider and a Consumer.
///
/// Given the [_providerState] and a [_description] of the interaction.
/// When the Provider receives a [_request] of the form X.
/// Then the Provider should send the [_response], Y.
class PactInteraction {
  String _providerState;
  String _description;
  Map _request;
  Map _response;

  /// Constructs an instance of [PactInteraction]
  PactInteraction() {
    _providerState = '';
    _description = '';
    _request = new Map();
    _response = new Map();
  }

  /// Returns this instance of [PactInteraction] with the provided [providerState] and [description].
  ///
  /// Throws [StateError] if either [providerState] or [description] is an empty String
  PactInteraction given(String providerState, String description) {
    if (providerState.isEmpty) {
      throw new StateError(
          'PactInteraction.given := `providerState` cannot be an empty String.');
    }
    _providerState = providerState;

    if (description.isEmpty) {
      throw new StateError(
          'PactInteraction.uponReceiving := `description` cannot be an empty String.');
    }
    _description = description;

    return this;
  }

  /// Returns the [_request] defined on this [PactInteraction]
  Map get request => _request;

  /// Returns the [_response] defined on this [PactInteraction]
  Map get response => _response;

  /// Returns this instance of [PactInteraction] with the provided [method] and [path].
  ///
  /// Supports the following optional parameters:
  /// * Map [headers] := any headers that should appear on the request
  /// * Map [query] := any query params that should appear on the request
  /// * Map [body] := the body that should appear on the request
  ///
  /// Throws [StateError] if either [method] or [path] is an empty String
  PactInteraction when(String method, String path,
      {Map headers, Map query, Map body}) {
    if (method.isEmpty || path.isEmpty) {
      throw new StateError(
          'PactInteraction.withRequest := `method` and `path` cannot be empty Strings');
    }
    _request['method'] = method;
    _request['path'] = path;

    if (query != null) {
      _request['query'] = query;
    }

    if (headers != null) {
      _request['headers'] = headers;
    }

    if (body != null) {
      _request['body'] = body;
    }

    return this;
  }

  /// Returns this instance of [PactInteraction] with the provided [status] the [_response] should use.
  ///
  /// Supports the following optional parameters:
  /// * Map [headers] := any headers that should appear on the response
  /// * Map [body] := the body that should appear on the response
  ///
  /// Throws a [StateError] if [status] is null.
  PactInteraction then(int status, {Map headers, Map body}) {
    if (status == null) {
      throw new StateError(
          'PactInteraction.willRespondWith := `status` cannot be null');
    }
    _response['status'] = status;

    if (headers != null) {
      _response['headers'] = headers;
    }

    if (body != null) {
      _response['body'] = body;
    }

    return this;
  }

  /// Returns this instance of [PactInteraction] as a [Map]
  Map toMap() {
    return {
      'provider_state': _providerState,
      'description': _description,
      'request': _request,
      'response': _response
    };
  }
}
