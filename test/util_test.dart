
import 'dart:convert';
import 'dart:io';
import 'package:unittest/unittest.dart';

import '../declarations.dart';

main() {  
  
  //remove all loaded handlers, and clean up resources
  tearDown(() {
    //app.tearDown();
    File file = new File('./streetEntities');
    if (file.existsSync())
    {
      file.deleteSync(recursive:true);
    }
  });

  test("empty street entities", () {  
    expect(getStreetEntities("tsid"), isEmpty);  
  });  
  test("create street entities JSON", () {
    File file = new File('./streetEntities/UNIT_TEST.json');
    file.createSync(recursive:true);
    var sink = file.openWrite();
    var testMap = {"test":"value"};
    sink.write(JSON.encode(testMap));
    sink.close();
    
    expect(getStreetEntities("UNIT_TEST.json"), containsPair("test", "value"));  
  });  
 } 