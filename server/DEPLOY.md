# SURGICALSIM Signaling Server - Deployment Guide

## Quick Deploy to Render.com (FREE)

### Step 1: Create GitHub Repository

1. Go to github.com
2. Create new repository: `surgicalsimsignaling`
3. Upload these files:
   - `server/signaling_server.js`
   - `server/package.json`

### Step 2: Deploy to Render.com

1. Go to [render.com](https://render.com)
2. Sign up (FREE)
3. Click **New Web Service**
4. Connect your GitHub repository
5. Configure:
   - **Name**: `surgicalsimsignaling`
   - **Runtime**: Node
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
   - **Port**: 10000
6. Click **Create Web Service**
7. Wait for deployment (~2 minutes)

### Step 3: Get Your Server URL

After deployment, you'll get a URL like:
```
https://surgicalsimsignaling.onrender.com
```

### Step 4: Update Game Config

1. Open `config/server_config.json`
2. Update the signaling_url:
```json
{
  "signaling_url": "wss://surgicalsimsignaling.onrender.com"
}
```
3. Save the file

### Step 5: Test Connection

1. Run the game
2. Click "Online Multiplayer"
3. Click "Connect to Server"
4. Should show "Connected to server!"

---

## Alternative: Deploy to Railway

1. Go to [railway.app](https://railway.app)
2. Sign up (FREE $5 credit)
3. Create new project
4. Deploy from GitHub
5. Use same configuration as Render

---

## Alternative: Deploy to Fly.io

1. Go to [fly.io](https://fly.io)
2. Install flyctl CLI
3. Run `fly launch`
4. Deploy

---

## Server Features

- ✅ Room creation with 6-character codes
- ✅ Room joining via code
- ✅ Player management (max 4 per room)
- ✅ WebRTC signaling (offer/answer/ICE)
- ✅ Auto-cleanup of empty rooms
- ✅ Health check endpoint

---

## Cost

| Platform | Monthly Cost |
|----------|-------------|
| Render.com | $0 (free tier) |
| Railway | $0 ($5 free credit) |
| Fly.io | $0 (free tier) |

---

## Troubleshooting

### Can't connect?
1. Check server URL is correct (wss:// not https://)
2. Check server is running (visit https://your-server.onrender.com/health)
3. Check firewall isn't blocking WebSocket connections

### Room not found?
1. Make sure both players use the same 6-character code
2. Codes are case-sensitive
3. Room may have been deleted if empty

### Connection drops?
1. WebRTC P2P may fail behind strict firewalls
2. Try again - connections are usually stable

---

## Server Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Server status |
| `/health` | GET | Health check |

---

## Environment Variables (Optional)

| Variable | Default | Description |
|----------|---------|-------------|
| PORT | 10000 | Server port |

---

## Support

If you have issues:
1. Check Render logs
2. Test with the health endpoint
3. Verify WebSocket connection in browser

---

## Next Steps

Once server is running:
1. Update `config/server_config.json` with your URL
2. Test online multiplayer in game
3. Share room codes with friends to play!
