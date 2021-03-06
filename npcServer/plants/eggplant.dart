part of coUserver;

class EggPlant extends Tree
{
	EggPlant(String id, int x, int y) : super(id,x,y)
	{
		type = "Egg Plant";

		responses =
		{
        	"harvest": [
        		"This. For you.",
        		"We grew this. You take.",
        		"This harvest good. Have it.",
        		"Ooooof. Take harvest. Heavy.",
        		"We made this. You can have.",
        	],
        	"pet": [
        		"Petting approved.",
        		"Think petting good. Builds brain.",
        		"Much gooder. Egg Plant grows in body and brain.",
        		"Egg plant grows stronger. Cleverer. And eggier.",
        		"Yes. Petting makes brain and eggs biggerer.",
        	],
        	"water": [
        		"Ahhhhh. Better.",
        		"Water good. We feel gratitude.",
        		"Glug. Thanks.",
        		"Yes. Liquid helps make harvests. Good.",
        		"Good watering. But we still like petting too, comprende?",
        	]
        };

		states =
			{
				"maturity_1" : new Spritesheet("maturity_1","http://c2.glitch.bz/items/2012-12-06/trant_egg__f_cap_10_f_num_10_h_10_m_1_seed_0_11191191_png_1354829612.png",888,278,296,278,3,false),
				"maturity_2" : new Spritesheet("maturity_2","http://c2.glitch.bz/items/2012-12-06/trant_egg__f_cap_10_f_num_10_h_10_m_2_seed_0_11191191_png_1354829613.png",888,278,296,278,3,false),
				"maturity_3" : new Spritesheet("maturity_3","http://c2.glitch.bz/items/2012-12-06/trant_egg__f_cap_10_f_num_10_h_10_m_3_seed_0_11191191_png_1354829614.png",592,556,296,278,4,false),
				"maturity_4" : new Spritesheet("maturity_4","http://c2.glitch.bz/items/2012-12-06/trant_egg__f_cap_10_f_num_10_h_10_m_4_seed_0_11191191_png_1354829616.png",888,1390,296,278,14,false),
				"maturity_5" : new Spritesheet("maturity_5","http://c2.glitch.bz/items/2012-12-06/trant_egg__f_cap_10_f_num_10_h_10_m_5_seed_0_11191191_png_1354829618.png",888,1946,296,278,19,false),
				"maturity_6" : new Spritesheet("maturity_6","http://c2.glitch.bz/items/2012-12-06/trant_egg__f_cap_10_f_num_10_h_10_m_6_seed_0_11191191_png_1354829621.png",888,2502,296,278,26,false),
				"maturity_7" : new Spritesheet("maturity_7","http://c2.glitch.bz/items/2012-12-06/trant_egg__f_cap_10_f_num_10_h_10_m_7_seed_0_11191191_png_1354829624.png",888,3336,296,278,34,false),
				"maturity_8" : new Spritesheet("maturity_8","http://c2.glitch.bz/items/2012-12-06/trant_egg__f_cap_10_f_num_10_h_10_m_8_seed_0_11191191_png_1354829628.png",888,3336,296,278,34,false),
				"maturity_9" : new Spritesheet("maturity_9","http://c2.glitch.bz/items/2012-12-06/trant_egg__f_cap_10_f_num_10_h_10_m_9_seed_0_11191191_png_1354829632.png",3256,1112,296,278,44,false),
				"maturity_10" : new Spritesheet("maturity_10","http://c2.glitch.bz/items/2012-12-06/trant_egg__f_cap_10_f_num_10_h_10_m_10_seed_0_11191191_png_1354829638.png",3256,1390,296,278,55,false)
			};
		maturity = new Random().nextInt(states.length)+1;
     	currentState = states['maturity_$maturity'];
     	state = new Random().nextInt(currentState.numFrames);
     	maxState = currentState.numFrames-1;
	}

	void harvest({WebSocket userSocket, String username})
	{
		super.harvest(userSocket:userSocket);

		//give the player the 'fruits' of their labor
		addItemToUser(userSocket,username,new Egg().getMap(),1,id);
	}
}