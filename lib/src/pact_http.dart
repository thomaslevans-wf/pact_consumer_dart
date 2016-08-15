import 'dart:async';
import 'package:w_transport/w_transport.dart';

class PactHttp {
  static Future makeRequest(String method, Uri uri, {Map body}) async {
    JsonRequest request = new JsonRequest();
    var headers = {
      'X-Pact-Mock-Service': 'true',
      'Content-Type': 'application/json'
    };

    try {
      if (body == null) {
        return request.send(method, headers: headers, uri: uri);
      } else {
        print('--------- PACT INTERACTION -----------');
        print(body.toString());
        print('--------- PACT INTERACTION -----------');
        return request.send(method, body: body, headers: headers, uri: uri);
      }
    } catch (e) {
      print(e);
    }
  }
}
