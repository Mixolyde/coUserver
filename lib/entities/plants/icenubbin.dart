part of entity;

class IceNubbin extends Plant {
	IceNubbin (String id, int x, int y, String streetName) : super(id, x, y, streetName) {
		actionTime = 2000;
		type = "Ice Nubbin";

		actions.add({
			"action":"collect",
			"actionWord":"breaking the ice",
			"timeRequired":actionTime,
			"enabled":true,
			"requires":[
				{
					"num":1,
					"of":["scraper", "super_scraper"],
					"error": "You need something sharp to cut off ice cubes with."
				},
				{
					"num":4,
					"of":['energy'],
					"error": "You need at least 4 energy to pull off ice cubes."
				}
			]
		});

		states = {
			"1-2-3-4-5" : new Spritesheet("1-2-3-4-5", "http://childrenofur.com/assets/entityImages/ice_knob.png", 290, 84, 58, 84, 5, false),
		};
		setState('1-2-3-4-5');
		state = new Random().nextInt(currentState.numFrames);
		maxState = 5;
	}

	Future<bool> collect ({WebSocket userSocket, String email}) async {
		//make sure the player has a shovel that can scrape this ice
		Map mineAction = actions.firstWhere((Map action) => action['action'] == 'collect');
		List<String> types = mineAction['requires'][0]['of'];
		bool success = await InventoryV2.decreaseDurability(email, types);
		if(!success) {
			return false;
		}

		success = await super.trySetMetabolics(email,energy:-4,imgMin:2,imgRange:2);
		if(!success) {
			return false;
		}

		int numToGive = 1;
		// 1 in 15 chance to get an extra
		if(new Random().nextInt(14) == 14) {
			numToGive = 2;
		}

		// Chance to get an ice cube
		// Chance to let it melt before you collect it
		if(new Random().nextInt(2) == 1) {
			await InventoryV2.addItemToUser(email, items['ice'].getMap(), numToGive, id);
			StatBuffer.incrementStat("iceNubbinsCollected", 1);
			state--;

			StatManager.add(email, Stat.ice_scraped).then((int scraped) {
				if (scraped >= 1777) {
					Achievement.find("icebreaker").awardTo(email);
				} else if (scraped >= 877) {
					Achievement.find("cold_as_ice").awardTo(email);
				} else if (scraped >= 467) {
					Achievement.find("on_thin_ice").awardTo(email);
				} else if (scraped >= 227) {
					Achievement.find("ice_ice_baby").awardTo(email);
				} else if (scraped >= 67) {
					Achievement.find("ice_baby").awardTo(email);
				}
			});
			
			if(state < 1) {
				respawn = new DateTime.now().add(new Duration(minutes:2));
				return false;
			}
			return true;
		} else {
			await InventoryV2.addItemToUser(email, items['cup_of_water'].getMap(), 1, id);
			say("You have to grab it faster next time. It melted!");
			return false;
		}
	}
}