library server_test;

import 'dart:convert';

import 'package:redstone/mocks.dart';
import 'package:redstone/server.dart' as app;
import 'package:unittest/unittest.dart';

import '../declarations.dart';

main() {  
  
  //load handlers in 'authServer' library
  setUp(() => app.setUp([#coUserver]));

  //remove all loaded handlers
  tearDown(() => app.tearDown());
  
  test("GET server status", () {
    //create a mock request
    var req = new MockRequest("/serverStatus");
    //dispatch the request
    return app.dispatch(req).then((resp) {
      //verify the response
      expect(resp.statusCode, equals(200));
      var content = JSON.decode(resp.mockContent);
      expect(content, containsPair("playerList", []));
      expect(content, containsPair("numStreetsLoaded", 0));
    });
  });

  
 }  

