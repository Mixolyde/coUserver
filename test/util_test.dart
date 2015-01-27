library util_test;

import 'dart:convert';
import 'dart:io';
import 'package:unittest/unittest.dart';

import '../declarations.dart';

main() {  
  
  //remove all loaded handlers, and clean up resources
  tearDown(() {
    //app.tearDown();
    Directory file = new Directory('./streetEntities');
    if (file.existsSync())
    {
      print("Deleting directory: $file");
      file.deleteSync(recursive:true);
    }
  });

  test("empty street entities", () {  
    expect(getStreetEntities("tsid"), isEmpty);  
  });  
  test("create street entities JSON", () {
    File file = new File('./streetEntities/UNIT_TEST.json');
    file.createSync(recursive:true);
    file.writeAsStringSync(
        JSON.encode({"test":"value"}));
    
    expect(getStreetEntities("UNIT_TEST.json"), containsPair("test", "value"));  
  });  
 } 