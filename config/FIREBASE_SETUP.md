# Firebase Setup Guide (FREE - Email Auth Only)

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **Create Project**
3. Enter project name: `surgicalsim`
4. Disable Google Analytics (not needed)
5. Click **Create Project**

---

## Step 2: Enable Email Auth (FREE)

1. In Firebase Console, go to **Authentication**
2. Click **Get Started**
3. Go to **Sign-in method** tab
4. Click **Email/Password**
5. Enable **Email/Password**
6. Click **Save**

**Cost: $0 forever** (email auth is free)

---

## Step 3: Get Config Values

1. Go to **Project Settings** (gear icon)
2. Scroll down to **Your apps**
3. Click **Web** icon (`</>`)
4. Enter app nickname: `surgicalsim-web`
5. Click **Register App**
6. Copy the config values

---

## Step 4: Update firebase_config.json

Edit `config/firebase_config.json`:

```json
{
  "api_key": "AIzaSyB...",
  "auth_domain": "surgicalsim.firebaseapp.com",
  "project_id": "surgicalsim",
  "storage_bucket": "surgicalsim.appspot.com",
  "messaging_sender_id": "123456789",
  "app_id": "1:123456789:web:abc123"
}
```

---

## Step 5: Test

1. Run the game
2. Click "Create Account"
3. Enter email and password
4. Click "Create Account"
5. Should show "Account created successfully!"

---

## Cost Breakdown

| Service | Free Tier | Your Usage | Cost |
|---------|-----------|------------|------|
| Email Auth | Unlimited | ~100 users | $0 |
| Firestore | 1 GB | ~0.01 GB | $0 |
| Hosting | 10 GB | Not used | $0 |
| **TOTAL** | | | **$0** |

---

## Features

- ✅ Email/Password registration
- ✅ Email/Password login
- ✅ Password reset via email
- ✅ User display name
- ✅ Secure token storage
- ✅ Works offline (cached)

---

## Troubleshooting

### "Firebase not configured"
- Check `config/firebase_config.json` exists
- Check API key is not empty

### "Email already registered"
- Use a different email
- Or use "Forgot Password"

### "Invalid password"
- Password must be at least 6 characters

---

## Security Rules (Optional)

If you add Firestore later, use these rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## Support

For issues:
1. Check Firebase Console for errors
2. Verify email auth is enabled
3. Check config values are correct
