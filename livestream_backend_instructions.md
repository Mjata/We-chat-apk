
# Maelekezo kwa Backend: Mfumo wa Live Stream

Habari Backend Developer,

Ili kukamilisha sehemu ya **Live Streaming** kwenye programu yetu, tunahitaji kuhakikisha `endpoints` zifuatazo zinafanya kazi kama ilivyoelezwa. Mfumo huu utaruhusu watumiaji kuanza, kusimamisha, na kuona orodha ya matangazo ya moja kwa moja (live streams).

---

### Mfumo Mkuu

Mantiki itahusisha `collection` mpya kwenye Firestore (kwa mfano, iitwe `live_streams`) ambayo itahifadhi orodha ya watumiaji wote ambao wako "live" kwa sasa. Kila mtumiaji aliye "live" atawakilishwa na `document` moja kwenye `collection` hii.

---

### Endpoint 1: Kuanza Live Stream

-   **URL**: `/api/livestreams/start`
-   **Method**: `POST`
-   **Authentication**: `authMiddleware` (inahitajika)

#### Maelezo:
`Endpoint` hii inaitwa na programu ya Flutter pale mtumiaji anapobonyeza kitufe cha "Go Live Now".

#### Kazi ya Kufanya:
1.  Thibitisha utambulisho wa mtumiaji kwa kutumia `Firebase ID Token` iliyopo kwenye `header`.
2.  Pata `UID` ya mtumiaji kutoka kwenye `token` hiyo.
3.  Unda `document` mpya ndani ya `live_streams` collection. `Document ID` inapaswa kuwa `UID` ya mtumiaji huyo.
4.  `Document` hiyo inapaswa kuwa na maelezo muhimu ya mtumiaji, kama vile:
    *   `userId` (UID yake)
    *   `username`
    *   `profilePictureUrl`
    *   `liveStreamImageUrl` (URL ya picha itakayotumika kama 'thumbnail' ya stream)
    *   `timestamp` (wakati stream ilipoanza)

#### Mfano wa `Document` Kwenye Firestore (`live_streams/{userId}`):
```json
{
  "userId": "Abc123xyzFirebaseUID",
  "username": "Juma Kondo",
  "profilePictureUrl": "https://example.com/profiles/juma.png",
  "liveStreamImageUrl": "https://example.com/stream_previews/juma_live.png",
  "startedAt": "2023-10-27T10:00:00Z"
}
```

#### Majibu (Response):
-   **Success (200 OK)**: Rudisha majibu tupu au `JSON` kuthibitisha kuwa operesheni imefanikiwa.
    ```json
    { "status": "success", "message": "Stream started and user is now live." }
    ```

---

### Endpoint 2: Kusimamisha Live Stream

-   **URL**: `/api/livestreams/stop`
-   **Method**: `POST`
-   **Authentication**: `authMiddleware` (inahitajika)

#### Maelezo:
`Endpoint` hii inaitwa na programu ya Flutter pale mtumiaji anapomaliza stream yake kwa kubonyeza "End Stream".

#### Kazi ya Kufanya:
1.  Thibitisha utambulisho wa mtumiaji.
2.  Pata `UID` ya mtumiaji.
3.  Futa `document` yenye `ID` inayolingana na `UID` ya mtumiaji huyo kutoka kwenye `live_streams` collection.

#### Majibu (Response):
-   **Success (200 OK)**: Rudisha majibu tupu au `JSON` kuthibitisha kuwa stream imesitishwa.
    ```json
    { "status": "success", "message": "Stream stopped." }
    ```

---

### Endpoint 3: Kupata Orodha ya Live Streams

-   **URL**: `/api/livestreams`
-   **Method**: `GET`
-   **Authentication**: `authMiddleware` (inahitajika)

#### Maelezo:
`Endpoint` hii inaitwa na programu ya Flutter inapotaka kuonyesha orodha ya watu wote ambao wako "live".

#### Kazi ya Kufanya:
1.  Soma `documents` zote zilizopo ndani ya `live_streams` collection.

#### Majibu (Response):
-   **Success (200 OK)**: Rudisha `JSON array` ambapo kila `object` kwenye `array` inawakilisha mtumiaji mmoja aliye "live".

#### Mfano wa Majibu (Response Body):
```json
[
  {
    "userId": "Abc123xyzFirebaseUID",
    "username": "Juma Kondo",
    "profilePictureUrl": "https://example.com/profiles/juma.png",
    "liveStreamImageUrl": "https://example.com/stream_previews/juma_live.png"
  },
  {
    "userId": "Def456uvwFirebaseUID",
    "username": "Asha Mrembo",
    "profilePictureUrl": "https://example.com/profiles/asha.png",
    "liveStreamImageUrl": "https://example.com/stream_previews/asha_live.png"
  }
]
```
**MUHIMU:** Hakikisha `userId` (ambayo ni UID ya mtiririshaji) inajumuishwa, kwa sababu programu ya Flutter itaitumia kama `roomName` wakati wa kuomba `token` ya kujiunga na stream ya mtazamaji.

---
Asante!
