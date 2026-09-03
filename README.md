# Twitter mobile app

Flutter client for the Twitter-style backend. Dark theme, Riverpod, cookie sessions — no `go_router`. Talks to the API over REST + WebSocket.

Pair with the API: [Twitter backend](https://github.com/samuel2l/Twitter-backend).

## What it does

- **Auth** — email/password and Google. Session cookies persist on disk.
- **Onboarding** — pick 1–5 topics after first login (powers For You).
- **Home** — Following and Explore (For You) tabs, compose FAB, notifications badge, profile.
- **Feeds** — pagination, pull-to-refresh, “new posts” banners.
- **Explore** — records impressions (debounced) so the recommender can exclude seen posts.
- **Posts** — compose (text + media), detail thread, replies, quote, repost.
- **Engagement** — like, bookmark, share — optimistic UI (instant, rollback on error).
- **Profile / social** — own and other profiles, follow, followers/following lists.
- **Notifications** — inbox, mark read, unread badge.
- **Realtime** — WebSocket for new-post and notification signals.
- **Push** — FCM token register/unregister when Firebase is configured (optional).

## Architecture

```
lib/
├── core/           # Dio + cookies, Google auth, WebSocket, FCM, shared models
├── utils/          # theme, .env, widgets (PostCard, etc.)
└── features/       # one folder per area: auth, following, explore, posts, …
```

Each feature is typically **repository → service → providers → screens/widgets**.

State is **Riverpod**. Networking is **Dio** with `PersistCookieJar` so Better Auth cookies work for REST and the WebSocket upgrade.

```
AuthGate → OnboardingGate → HomeScreen
                │
                ├── Following tab  (timeline/following)
                └── Explore tab    (timeline/for-you + impressions)
```

## Setup

1. Backend running (`npm run dev` in [Twitter-backend](https://github.com/samuel2l/Twitter-backend)).
2. Copy env:

```bash
cp .env.example .env
```

3. Set `API_BASE_URL` to **this machine as seen from the device**:

| Where the app runs | `API_BASE_URL` |
|--------------------|----------------|
| iOS Simulator | `http://localhost:3000` |
| Android Emulator | `http://10.0.2.2:3000` |
| Physical device | `http://YOUR_LAN_IP:3000` |

`localhost` inside the Android emulator is the emulator itself, not your Mac — that’s why Android uses `10.0.2.2`.

Optional:

```env
GOOGLE_CLIENT_ID=your-web-client-id.apps.googleusercontent.com
```

Same Google **web** client ID as the backend. Skip this if you only use email login.

4. Run:

```bash
flutter pub get
flutter run
```

iOS deployment target is **15.0** (required by `firebase_core`).

Seeded backend accounts: `alphacoder@seed.local` / `11111111` (and the other `*@seed.local` users).

## Env

Flutter does not read the backend `.env`. Only this app’s `.env` (loaded via `flutter_dotenv`):

| Var | Required | Meaning |
|-----|----------|---------|
| `API_BASE_URL` | yes | REST base; WebSocket URL is derived (`ws`/`wss` + `/ws`) |
| `GOOGLE_CLIENT_ID` | no | Google Sign-In server client ID |

You can still override with `--dart-define=API_BASE_URL=...` if you prefer; `.env` wins when set.

## Optional: Google and push

**Google** — set `GOOGLE_CLIENT_ID`, plus platform OAuth config (iOS URL scheme / Android SHA-1 in Google Cloud).

**FCM** — `flutterfire configure` so `Firebase.initializeApp()` succeeds. Without it, the app still runs; push init is skipped. Backend needs `FCM_ENABLED=true`.

## Layout (features)

| Feature | Screens / behavior |
|---------|-------------------|
| `auth` | Login, register, session gate |
| `onboarding` | Topic chips, status gate |
| `home` | Tab shell, notifications icon |
| `following` | Chronological follow feed |
| `explore` | For You, session id, impressions |
| `posts` | Compose, detail, media upload |
| `engagement` | Like / bookmark / share bar |
| `profile` | User header + posts |
| `social` | Follow button, lists |
| `notifications` | Inbox |

## Tests

```bash
flutter analyze lib test
flutter test
```
