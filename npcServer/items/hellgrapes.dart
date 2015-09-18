part of coUserver;

class HellGrapes extends Plant {
  HellGrapes(String id, int x, int y) : super(id, x, y) {
    actionTime = 3000;
    type = "Hellish Grapes";

    actions.add({
      "action": "squish",
      "actionWord": "squishing",
      "description": "You have to work to get out.",
      "timeRequired": 0,
      "enabled": true,
      "requires": []
    });

    states = {
      "grapes": new Spritesheet("1-2-3-4", "http://childrenofur.com/assets/entityImages/bunch_of_grapes__x1_1_x1_2_x1_3_x1_4_png_1354829730.png", 228, 30, 57, 30, 1, true)
    };
    currentState = states["grapes"];
    state = 0;
    maxState = 0;
  }

  @override
  void update() {
    if (state == 0) {
      setActionEnabled("squish", true);
    }

    if (respawn != null && new DateTime.now().compareTo(respawn) >= 0) {
      state = 0;
      setActionEnabled("squish", true);
      respawn = null;
    }

    if (state < maxState){
      state = maxState;
    }
  }

  Future<bool> squish({WebSocket userSocket, String email}) async {
    if (state > 1) {
      return false;
    }
    bool success = await trySetMetabolics(email, energy: 3);
    if (!success) {
      return false;
    }

    // Update global stat
    StatBuffer.incrementStat("grapesSquished", 1);
    // Hide
    setActionEnabled("squish", false);
    state = 5;
    // Show after 2 minutes
    respawn = new DateTime.now().add(new Duration(minutes: 2));
    return success;
  }
}
