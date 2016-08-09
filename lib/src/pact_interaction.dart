class PactInteraction {
  String providerState;
  String description;
  Map request;
  Map response;

  PactInteraction() {
    this.providerState = null;
    this.description = '';
    this.request = new Map();
    this.response = new Map();
  }

  PactInteraction given(String providerState) {
    this.providerState = providerState;
    return this;
  }

  PactInteraction uponReceiving(String description) {
    if (description.isEmpty) {
      throw new StateError(
          'PactInteraction.uponReceiving := `description` cannot be an empty String.');
    }
    this.description = description;
    return this;
  }

  PactInteraction withRequest(String method, String path, {Map opts}) {
    if (method.isEmpty || path.isEmpty) {
      throw new StateError(
          'PactInteraction.withRequest := `method` and `path` cannot be empty Strings');
    }
    this.request['method'] = method;
    this.request['path'] = path;

    if (opts != null) {
      if (opts.containsKey('query')) {
        this.request['query'] = opts['query'];
      }

      if (opts.containsKey('headers')) {
        this.request['headers'] = opts['headers'];
      }

      if (opts.containsKey('body')) {
        this.request['body'] = opts['body'];
      }
    }

    return this;
  }

  PactInteraction willRespondWith(int status, {Map headers, Map body}) {
    if (status == null) {
      throw new StateError(
          'PactInteraction.willRespondWith := `status` cannot be null');
    }
    this.response['status'] = status;

    if (headers != null) {
      this.response['headers'] = headers;
    }

    if (body != null) {
      this.response['body'] = body;
    }

    return this;
  }

  Map toMap() {
    return {
      'providerState': this.providerState,
      'description': this.description,
      'request': this.request,
      'response': this.response
    };
  }
}
