import 'dart:async';

import 'package:pact_consumer_dart/src/pact_http.dart';

class PactMockServiceRequests {
  static Future getVerification(String baseUrl) async {
    Uri uri = Uri.parse(baseUrl + '/interactions/verification');
    return PactHttp.makeRequest('GET', uri);
  }

  static Future putInteractions(List interactions, String baseUrl) async {
    Uri uri = Uri.parse(baseUrl + '/interactions');
    return PactHttp
        .makeRequest('PUT', uri, body: {'interactions': interactions});
  }

  static Future deleteInteractions(String baseUrl) async {
    Uri uri = Uri.parse(baseUrl + '/interactions');
    return PactHttp.makeRequest('DELETE', uri);
  }

  static Future postInteractions(dynamic interaction, String baseUrl) async {
    Uri uri = Uri.parse(baseUrl + '/interactions');
    return PactHttp.makeRequest('POST', uri, body: interaction);
  }

  static Future postPact(dynamic pactDetails, String baseUrl) async {
    Uri uri = Uri.parse(baseUrl + '/pact');
    return PactHttp.makeRequest('POST', uri, body: pactDetails);
  }

  static Future deleteSession(String baseUrl) async {
    Uri uri = Uri.parse(baseUrl + '/session');
    return PactHttp.makeRequest('DELETE', uri);
  }
}
