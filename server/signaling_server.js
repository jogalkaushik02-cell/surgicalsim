// WebRTC Signaling Server (Node.js)
// Deploy on Render.com (free tier)
// Run: node signaling_server.js

const express = require('express');
const http = require('http');
const WebSocket = require('ws');
const path = require('path');

const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

const PORT = process.env.PORT || 10000;

// Store rooms and players
const rooms = new Map();
const players = new Map();

// Rate limiting
const RATE_LIMIT_WINDOW = 60000; // 1 minute
const RATE_LIMIT_MAX_MESSAGES = 50;
const connectionTimestamps = new Map();

function isRateLimited(peerId) {
    const now = Date.now();
    const timestamps = connectionTimestamps.get(peerId) || [];
    const recentTimestamps = timestamps.filter(t => now - t < RATE_LIMIT_WINDOW);
    if (recentTimestamps.length >= RATE_LIMIT_MAX_MESSAGES) {
        return true;
    }
    recentTimestamps.push(now);
    connectionTimestamps.set(peerId, recentTimestamps);
    return false;
}

// Generate unique peer ID
let nextPeerId = 1;
function generatePeerId() {
    return nextPeerId++;
}

// Generate room code
function generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let code = '';
    for (let i = 0; i < 6; i++) {
        code += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return code;
}

// WebSocket connection handler
wss.on('connection', (ws) => {
    const peerId = generatePeerId();
    players.set(peerId, { ws, roomCode: null, info: {} });
    
    console.log(`Player connected: ${peerId}`);
    
    // Send welcome message
    ws.send(JSON.stringify({
        type: 'welcome',
        peer_id: peerId
    }));
    
    ws.on('message', (message) => {
        if (isRateLimited(peerId)) {
            ws.send(JSON.stringify({ type: 'error', message: 'Rate limit exceeded' }));
            return;
        }
        try {
            const data = JSON.parse(message.toString());
            handleMessage(peerId, data);
        } catch (e) {
            console.error('Invalid message:', e);
        }
    });
    
    ws.on('close', () => {
        connectionTimestamps.delete(peerId);
        const player = players.get(peerId);
        if (player && player.roomCode) {
            const room = rooms.get(player.roomCode);
            if (room) {
                room.players.delete(peerId);
                
                // Notify other players
                room.players.forEach(otherPeerId => {
                    const otherPlayer = players.get(otherPeerId);
                    if (otherPlayer && otherPlayer.ws.readyState === WebSocket.OPEN) {
                        otherPlayer.ws.send(JSON.stringify({
                            type: 'player_left',
                            peer_id: peerId
                        }));
                    }
                });
                
                // Delete room if empty
                if (room.players.size === 0) {
                    rooms.delete(player.roomCode);
                }
            }
        }
        players.delete(peerId);
        console.log(`Player disconnected: ${peerId}`);
    });
});

function handleMessage(peerId, data) {
    const player = players.get(peerId);
    
    switch (data.type) {
        case 'create_room':
            const roomCode = data.room_code || generateRoomCode();
            rooms.set(roomCode, { players: new Set([peerId]) });
            player.roomCode = roomCode;
            
            player.ws.send(JSON.stringify({
                type: 'room_joined',
                room_code: roomCode
            }));
            break;
            
        case 'join_room':
            const joinCode = data.room_code;
            const room = rooms.get(joinCode);
            
            if (!room) {
                player.ws.send(JSON.stringify({
                    type: 'error',
                    message: 'Room not found'
                }));
                return;
            }
            
            if (room.players.size >= 4) {
                player.ws.send(JSON.stringify({
                    type: 'error',
                    message: 'Room is full'
                }));
                return;
            }
            
            // Notify existing players
            room.players.forEach(otherPeerId => {
                const otherPlayer = players.get(otherPeerId);
                if (otherPlayer && otherPlayer.ws.readyState === WebSocket.OPEN) {
                    otherPlayer.ws.send(JSON.stringify({
                        type: 'player_joined',
                        peer_id: peerId,
                        info: player.info
                    }));
                }
            });
            
            // Add to room
            room.players.add(peerId);
            player.roomCode = joinCode;
            
            // Send room info to new player
            const existingPlayers = [];
            room.players.forEach(id => {
                if (id !== peerId) {
                    const p = players.get(id);
                    if (p) {
                        existingPlayers.push({ peer_id: id, info: p.info });
                    }
                }
            });
            
            player.ws.send(JSON.stringify({
                type: 'room_joined',
                room_code: joinCode,
                existing_players: existingPlayers
            }));
            break;
            
        case 'leave_room':
            if (player.roomCode) {
                const leaveRoom = rooms.get(player.roomCode);
                if (leaveRoom) {
                    leaveRoom.players.delete(peerId);
                    
                    // Notify others
                    leaveRoom.players.forEach(otherPeerId => {
                        const otherPlayer = players.get(otherPeerId);
                        if (otherPlayer && otherPlayer.ws.readyState === WebSocket.OPEN) {
                            otherPlayer.ws.send(JSON.stringify({
                                type: 'player_left',
                                peer_id: peerId
                            }));
                        }
                    });
                    
                    if (leaveRoom.players.size === 0) {
                        rooms.delete(player.roomCode);
                    }
                }
                player.roomCode = null;
            }
            break;
            
        // WebRTC signaling messages
        case 'offer':
        case 'answer':
        case 'ice_candidate':
            const targetPeerId = data.target_peer;
            const targetPlayer = players.get(targetPeerId);
            
            if (targetPlayer && targetPlayer.ws.readyState === WebSocket.OPEN) {
                data.from_peer = peerId;
                targetPlayer.ws.send(JSON.stringify(data));
            }
            break;
    }
}

// Health check endpoint
app.get('/', (req, res) => {
    res.json({
        status: 'running',
        players: players.size,
        rooms: rooms.size
    });
});

app.get('/health', (req, res) => {
    res.json({ status: 'ok' });
});

// Start server
server.listen(PORT, () => {
    console.log(`Signaling server running on port ${PORT}`);
});
