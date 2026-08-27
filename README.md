# SURGICALSIM - 3D Surgical Training Simulator

## Complete System Overview

### Features
- ✅ 3D Operating Room with realistic lighting
- ✅ Multiple surgical instruments (Scalpel, Forceps, Retractor, Suture)
- ✅ Step-by-step appendicectomy procedure
- ✅ Real-time vital signs monitoring
- ✅ Bleeding simulation
- ✅ AI team members (single player)
- ✅ Local multiplayer (same device)
- ✅ Online multiplayer (WebRTC P2P - FREE)
- ✅ Tutorial system (10 steps)
- ✅ Achievement system (15 achievements)
- ✅ Surgery catalog (11 surgeries)
- ✅ Local account system
- ✅ Local save/load system
- ✅ Local leaderboard
- ✅ Android touch controls
- ✅ Sound effects
- ✅ Particle effects

---

## Online Multiplayer Setup

### Step 1: Deploy Signaling Server (FREE)

See `server/DEPLOY.md` for detailed instructions.

Quick version:
1. Create GitHub repo with `server/signaling_server.js` and `server/package.json`
2. Deploy to Render.com (FREE)
3. Update `config/server_config.json` with your URL

### Step 2: Update Config

Edit `config/server_config.json`:
```json
{
  "signaling_url": "wss://your-server-name.onrender.com"
}
```

### Step 3: Play Online!

1. Launch game
2. Click "Online Multiplayer"
3. Click "Connect to Server"
4. Host creates room → gets 6-character code
5. Joiner enters code → joins room
6. Play together!

---

## Cost Breakdown

| Item | Cost |
|------|------|
| Signaling Server | $0 (Render.com free tier) |
| Game Development | $0 (local files) |
| Player Accounts | $0 (local storage) |
| Game Saves | $0 (local storage) |
| **TOTAL** | **$0/month** |

---

## File Structure

```
SURGICALSIM/
├── config/
│   ├── server_config.json      # Server configuration
│   └── firebase_config.json    # (deprecated, can delete)
├── core/
│   ├── auth_manager.gd         # Local user auth
│   ├── local_save_manager.gd   # Local saves/scores
│   ├── webrtc_manager.gd       # Online multiplayer
│   ├── sync_manager.gd         # Game state sync
│   ├── event_bus.gd            # Global signals
│   ├── simulation_manager.gd   # Game state
│   ├── role_system.gd          # Player roles
│   └── network_manager.gd      # ENet multiplayer
├── surgery/
│   ├── tutorial.gd             # Tutorial system
│   ├── achievement_system.gd   # Achievements
│   ├── surgery_catalog.gd      # Surgery list
│   ├── appendicectomy_state_machine.gd
│   ├── bleeding_simulation.gd
│   ├── ai_controller.gd
│   ├── sound_manager.gd
│   ├── particle_system.gd
│   ├── communication_system.gd
│   ├── patient_generator.gd
│   ├── tissue_deformation.gd
│   ├── realistic_timing.gd
│   └── haptic_feedback.gd
├── ui/
│   ├── main_menu.gd            # Main menu (login + features)
│   ├── tutorial_ui.gd          # Tutorial interface
│   ├── achievement_ui.gd       # Achievement display
│   ├── surgery_catalog_ui.gd   # Browse surgeries
│   ├── online_lobby_ui.gd      # Online multiplayer lobby
│   ├── login_ui.gd             # Login screen
│   ├── leaderboard_ui.gd       # Local leaderboard
│   ├── hud.gd                  # In-game HUD
│   ├── results_screen.gd       # Post-surgery results
│   └── ...
├── server/
│   ├── signaling_server.js     # WebRTC signaling server
│   ├── package.json            # Server dependencies
│   └── DEPLOY.md               # Deployment guide
└── scenes/
    └── main.tscn               # Main scene
```

---

## How to Play

### Single Player
1. Launch game
2. Click "Single Player"
3. You are Lead Surgeon, AI fills other roles
4. Follow tutorial or jump into surgery

### Local Multiplayer
1. Click "Local Multiplayer"
2. Assign roles for each player
3. Pass device between players

### Online Multiplayer
1. Click "Online Multiplayer"
2. Click "Connect to Server"
3. Host: Click "Create New Room" → share code
4. Joiner: Enter code → Click "Join"
5. Host: Click "Start Game"

---

## Surgery Catalog

### Available Now
- **Appendicectomy** (Beginner) - Full working surgery

### Coming Soon
- Cholecystectomy (Intermediate)
- Hernia Repair (Beginner)
- Exploratory Laparotomy (Advanced)
- Thyroidectomy (Advanced)
- Mastectomy (Advanced)
- Colectomy (Expert)
- Nephrectomy (Expert)
- Splenectomy (Intermediate)
- Craniotomy (Expert)
- Total Knee Replacement (Intermediate)

*Note: Coming soon surgeries are listed but not yet playable. They will be added after receiving positive feedback from real surgeons.*

---

## Achievements (15 Total)

| Achievement | Requirement |
|-------------|-------------|
| First Steps | Complete first surgery |
| Perfect Score | Get 100% |
| Speed Demon | Complete in <3 min |
| Bloodless | Zero bleeding |
| Getting Started | Complete 5 surgeries |
| Experienced | Complete 10 surgeries |
| Veteran | Complete 25 surgeries |
| Master Surgeon | Complete 50 surgeries |
| Team Player | 5 multiplayer surgeries |
| Leader | 10 as Lead Surgeon |
| Assistant Pro | 10 as Assistant |
| Nurse Expert | 10 as Scrub Nurse |
| Quick Learner | Complete tutorial |
| Jack of All Trades | Play all 4 roles |
| Crisis Manager | 5 with complications |

---

## Validation

Run `./validate.sh` to check project structure.

---

## Version

Current version: **0.6.0**

---

## Support

For issues:
1. Check `server/DEPLOY.md` for server setup
2. Run `./validate.sh` to check project
3. Check console for error messages

---

## License

Educational use only.
