
# Backend Instructions for LiveKit Integration

Hello Backend Developer,

The Flutter application has been updated to use LiveKit for video and voice calls, replacing the old system. To make this functional, we need a new, secure endpoint on our backend server that generates access tokens for LiveKit.

Here are the required steps:

---

### Step 1: Get LiveKit Credentials

You need to retrieve the API credentials from the LiveKit Cloud dashboard.

1.  Log in to [LiveKit Cloud](https://cloud.livekit.io/).
2.  Select the project (`we-chat-k0bb5qx2`).
3.  Navigate to **Settings** -> **Keys**.
4.  You will find two critical values:
    *   **API Key** (e.g., `API...`)
    *   **API Secret** (e.g., `secret...`)

These credentials are required for the backend to authenticate with LiveKit's servers.

---

### Step 2: Configure Environment Variables on Render

For security, these credentials **must not** be hardcoded in the source code. Please add them as environment variables in the Render dashboard for our backend service.

1.  Go to your Render.com dashboard.
2.  Select the backend service.
3.  Go to the **"Environment"** section.
4.  Add two new secret files/environment variables:
    *   **Key:** `LIVEKIT_API_KEY`
    *   **Value:** Paste the API Key you copied from the LiveKit dashboard.
    *   **Key:** `LIVEKIT_API_SECRET`
    *   **Value:** Paste the API Secret you copied from the LiveKit dashboard.

The server will need to be restarted to apply these new variables.

---

### Step 3: Create the LiveKit Token Endpoint

We need a new, protected API endpoint that the Flutter app can call to get a temporary access token.

#### Endpoint Details:
- **URL**: `/api/calls/livekit-token`
- **Method**: `POST`
- **Authentication**: This endpoint must be protected. The Flutter app automatically sends the user's Firebase ID Token in the request header (`Authorization: Bearer <ID_TOKEN>`). Your backend must verify this token before proceeding. You should already have a middleware for this.

#### Request Body:
The endpoint should expect a JSON body with the following structure:
```json
{
  "roomName": "some-unique-channel-name",
  "participantIdentity": "firebase-user-uid" 
}
```

#### Implementation (Node.js / Express Example):

1.  **Install SDKs**:
    Make sure you have the `livekit-server-sdk` and `firebase-admin` packages installed.
    ```bash
    npm install livekit-server-sdk firebase-admin
    ```

2.  **Endpoint Logic**:
    Here is a complete example of how to implement the endpoint. It includes Firebase authentication and token generation.

    ```javascript
    const express = require('express');
    const router = express.Router();
    const { AccessToken } = require('livekit-server-sdk');
    const admin = require('firebase-admin'); // Your existing firebase-admin instance

    // This is your Firebase authentication middleware
    const firebaseAuthMiddleware = async (req, res, next) => {
      const authHeader = req.headers.authorization;
      if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).send('Unauthorized: No token provided.');
      }
      const idToken = authHeader.split('Bearer ')[1];
      try {
        // Verify the token
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        req.user = decodedToken; // Add user info to the request object
        next();
      } catch (error) {
        return res.status(403).send('Unauthorized: Invalid token.');
      }
    };

    // Define the new endpoint
    router.post('/livekit-token', firebaseAuthMiddleware, (req, res) => {
      // 1. Get API Key and Secret from environment variables
      const apiKey = process.env.LIVEKIT_API_KEY;
      const apiSecret = process.env.LIVEKIT_API_SECRET;

      // 2. Get roomName and participantIdentity from the request body
      const { roomName, participantIdentity } = req.body;
      
      // 3. Get the authenticated user's UID from the middleware
      const authenticatedUserId = req.user.uid;

      // Security Check: Ensure the person requesting the token is the same person who will use it
      if (participantIdentity !== authenticatedUserId) {
        return res.status(403).json({ error: 'Forbidden: You can only request a token for yourself.' });
      }

      // 4. Validate inputs
      if (!apiKey || !apiSecret) {
        console.error('LiveKit server keys are not configured on the backend.');
        return res.status(500).json({ error: 'LiveKit server keys are not configured.' });
      }
      if (!roomName || !participantIdentity) {
        return res.status(400).json({ error: 'roomName and participantIdentity are required.' });
      }

      // 5. Create an AccessToken
      const at = new AccessToken(apiKey, apiSecret, {
        identity: participantIdentity,
        // You can also add user's name or metadata
        // name: req.user.name, 
      });

      // 6. Grant permissions to join the room
      at.addGrant({
        room: roomName,
        roomJoin: true,
        canPublish: true,      // Allow sending audio/video
        canSubscribe: true,    // Allow receiving audio/video
        // Set a timeout for the token
        // roomCreate: false, // Don't allow creating rooms
      });

      // 7. Generate the token (JWT)
      const token = at.toJwt();
      
      console.log(`Successfully generated LiveKit token for user: ${participantIdentity}`);
      
      // 8. Send the token back to the Flutter app
      return res.status(200).json({ token: token });
    });

    module.exports = router;
    ```

Thank you!
