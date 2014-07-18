library coUserver;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import "package:http/http.dart" as http;
import "package:http_server/http_server.dart";

//common to all server parts
part 'common/identifier.dart';

//chat server parts
part 'chatServer/irc_relay.dart';
part 'chatServer/keep_alive.dart';
part 'chatServer/chat_handler.dart';

//multiplayer server parts
part 'multiplayerServer/player_update_handler.dart';

//npc server (street simulation) parts
part 'npcServer/street_update_handler.dart';
part 'npcServer/street.dart';

//various http parts (as opposed to the previous websocket parts)
part 'web/stress_test.dart';

part 'multiplayerServer/gps.dart';

part 'util.dart';

IRCRelay relay;

void main() 
{
	int port = 8080;
	try	{port = int.parse(Platform.environment['PORT']);} //Platform.environment['PORT'] is for deployed, 8080 is for localhost
	catch (error){port = 8181;}
	HttpServer.bind('0.0.0.0', port).then((HttpServer server) 
	{
		//setup the IRCRelay
		relay = new IRCRelay();
		
		server.listen((HttpRequest request)
		{
			//if(request.uri.path == "/stressTest")
				//new StressTest(request);
			if(request.uri.path == "/serverStatus")
			{
				Map statusMap = {};
				List<String> users = [];
				ChatHandler.users.forEach((Identifier user)
				{
					if(!users.contains(user.username))
						users.add(user.username);
				});
				statusMap['playerList'] = users;
				statusMap['numStreetsLoaded'] = StreetUpdateHandler.streets.length;
				ProcessResult result = Process.runSync("/bin/sh",["getMemoryUsage.sh"]);
				statusMap['bytesUsed'] = int.parse(result.stdout)*1024;
				result = Process.runSync("/bin/sh",["getCpuUsage.sh"]);
				statusMap['cpuUsed'] = double.parse(result.stdout.trim());
				result = Process.runSync("/bin/sh",["getUptime.sh"]);
                statusMap['uptime'] = result.stdout.trim();
				request.response
					..headers.add('Access-Control-Allow-Origin', '*')
					..headers.add('Content-Type', 'application/json')
					..write(JSON.encode(statusMap))
					..close();
			}
			else if(request.uri.path == "/serverLog")
			{
				Map statusMap = {};
				try
				{
					statusMap['serverLog'] = new File('server.log').readAsStringSync();
				}
				catch(exception, stacktrace)
				{
					statusMap['serverLog'] = exception.toString();
				}
				request.response
					..headers.add('Access-Control-Allow-Origin', '*')
					..headers.add('Content-Type', 'application/json')
					..write(JSON.encode(statusMap))
					..close();
			}
			else if(request.uri.path == "/restartServer")
			{
				//TODO this should probably be secured - don't care right now
				Process.runSync("/bin/sh",["restart_server.sh"]);
			}
			else if(request.uri.path == "/slack")
			{
				Map data = request.uri.queryParameters;
				String username = data['user_name'];
				String text = data['text'];
				if(username == "robertmcdermot" && text.contains("::"))
				{
					request.response..write("OK")..close();
					return;
				}
				
				Map message = {'username':'dev_$username','channel':'Global Chat'};
				if(text != null)
					message['message'] = text;
				else
					message['message'] = "";
				ChatHandler.sendAll(JSON.encode(message));
				
				request.response..write("OK")..close();
			}
			else if(request.uri.path == "/entityUpload")
			{
				HttpBodyHandler.processRequest(request).then((HttpBody body)
				{
					Map params = body.body;
    				String tsid = params['tsid'];
    				
    				request.response
    				        ..headers.add('Access-Control-Allow-Origin', '*')
                            ..headers.add('Content-Type', 'application/json');
    				if(tsid == null)
    				{
    					request.response..write("FAIL")..close();
    					return;
    				}
    				
    				saveStreetData(params);
    				
    				request.response..write("OK")..close();
				});
			}
			else if(request.uri.path == "/getEntities")
			{
				Map data = request.uri.queryParameters;
				String tsid = data['tsid'];
				request.response
					..headers.add('Access-Control-Allow-Origin', '*')
					..headers.add('Content-Type', 'application/json')
					..write(JSON.encode(getStreetEntities(tsid)))
					..close();
			}
			else
			{
				WebSocketTransformer.upgrade(request).then((WebSocket websocket) 
				{
					if(request.uri.path == "/")
						new ChatHandler(websocket);
					else if(request.uri.path == "/playerUpdate")
						new PlayerUpdateHandler(websocket);
					else if(request.uri.path == "/streetUpdate")
						new StreetUpdateHandler(websocket);
				})
				.catchError((error)
				{
					print("error: $error");
				},
				test: (Exception e) => e is! WebSocketException)
				.catchError((error){},test: (Exception e) => e is WebSocketException);
			}
		});
			
		print('${new DateTime.now().toString()}\nServing Chat on ${'0.0.0.0'}:$port.');
	});
}