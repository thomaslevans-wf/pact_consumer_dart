class PactInteraction {
  String _providerState;
  String _description;
  Map _request;
  Map _response;

  PactInteraction() {
    _providerState = '';
    _description = '';
    _request = new Map();
    _response = new Map();
  }

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

  Map get request => _request;
  Map get response => _response;

  PactInteraction uponReceiving(String description) {
    if (description.isEmpty) {
      throw new StateError(
          'PactInteraction.uponReceiving := `description` cannot be an empty String.');
    }
    _description = description;
    return this;
  }

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

  Map toMap() {
    return {
      'provider_state': _providerState,
      'description': _description,
      'request': _request,
      'response': _response
    };
  }
}
