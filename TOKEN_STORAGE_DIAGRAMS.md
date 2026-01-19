# Token Storage - Visual Diagrams & Infographics

## 1. Complete Token Storage Lifecycle

```
                          LOGIN SCREEN
                              │
                              ▼
                    Email: john@example.com
                    Password: ••••••••
                              │
                              ▼
                    ┌─────────────────────┐
                    │  AuthController     │
                    │  .login()           │
                    └─────────┬───────────┘
                              │
                              ▼
                    ┌─────────────────────┐
                    │  ApiService         │
                    │  .login()           │
                    └─────────┬───────────┘
                              │
                              ▼
                    ┌─────────────────────┐
                    │  ApiClient          │
                    │  POST /api/login    │
                    └─────────┬───────────┘
                              │
                              ▼
                    ╔═════════════════════╗
                    ║  SERVER RESPONSE    ║
                    ╠═════════════════════╣
                    ║ {                   ║
                    ║   "token": "2|xyz.."║ ◄─ EXTRACT TOKEN
                    ║   "user": {...}     ║
                    ║ }                   ║
                    ╚═════════════════════╝
                              │
                              ▼
                    ┌─────────────────────┐
                    │ _client.authToken = │
                    │ response['token']   │
                    └─────────┬───────────┘
                              │
                              ▼
            ┌─────────────────────────────────────────┐
            │  GetStorage.write('auth_token', token)  │
            │           (Persistent Storage)          │
            └─────────────┬───────────────────────────┘
                          │
                          ▼
        ┌──────────────────────────────────────┐
        │  Device Storage                      │
        ├──────────────────────────────────────┤
        │  Android: SharedPreferences          │
        │  iOS: UserDefaults                   │
        └──────────────────────────────────────┘
                          │
         ┌────────────────┴────────────────┐
         ▼                                 ▼
    ┌─────────────────┐        ┌──────────────────┐
    │ SESSION ACTIVE  │        │ TOKEN AVAILABLE  │
    │ isLoggedIn=true │        │ for API requests │
    └─────────────────┘        └──────────────────┘
```

---

## 2. Token Usage in API Requests

```
         USER ACTION
    (Tap: Get Songs)
              │
              ▼
    ┌──────────────────────┐
    │ ApiService.getSongs()│
    └──────────┬───────────┘
               │
               ▼
    ┌──────────────────────────────┐
    │ ApiClient.get(endpoint)      │
    │ - Build HTTP request         │
    └──────────┬──────────────────┘
               │
               ▼
    ┌──────────────────────────────┐
    │ _headers getter called       │
    │                              │
    │ if (authToken != null) {     │
    │   'Authorization':           │
    │   'Bearer $authToken'        │
    │ }                            │
    └──────────┬──────────────────┘
               │
               ▼
    ┌──────────────────────────────┐
    │ HTTP Request Sent            │
    ├──────────────────────────────┤
    │ GET /api/songs HTTP/1.1      │
    │ Host: music-api.free.nf      │
    │ Authorization: Bearer 2|xyz.│  ◄─ TOKEN INCLUDED
    │ Content-Type: application/..│
    │ Accept: application/json     │
    └──────────┬──────────────────┘
               │
               ▼
    ┌──────────────────────────────┐
    │ ✅ SERVER VALIDATES TOKEN    │
    │ ✅ Returns songs data        │
    └──────────┬──────────────────┘
               │
               ▼
    ┌──────────────────────────────┐
    │ UI Updates with songs        │
    │ User sees: [Song 1]          │
    │            [Song 2]          │
    │            [Song 3]          │
    └──────────────────────────────┘
```

---

## 3. App Restart & Session Recovery

```
                    APP CLOSED
                        │
                        ▼
        ┌───────────────────────────┐
        │  Device Storage Still     │
        │  Contains:                │
        │  • auth_token: 2|xyz...   │
        │  • user_data: {...}       │
        │  • isLoggedIn: true       │
        └───────────────┬───────────┘
                        │
                        ▼
                    APP REOPENED
                        │
                        ▼
            ┌───────────────────────────┐
            │ main() runs               │
            │ runApp(MyApp())           │
            └───────────────┬───────────┘
                            │
                            ▼
            ┌───────────────────────────┐
            │ AuthController            │
            │ .onInit()                 │
            └───────────────┬───────────┘
                            │
                            ▼
            ┌───────────────────────────┐
            │ _loadInitialState()       │
            │                           │
            │ isLoggedIn =              │
            │ storage.read('isLoggedIn')│
            │                           │
            │ currentUser =             │
            │ offlineStorage.getUser()  │
            └───────────────┬───────────┘
                            │
                            ▼
                    ╔═════════════════╗
                    ║ CHECK: Was user ║
                    ║ logged in?      ║
                    ╚═════════╤═══════╝
                              │
                ┌─────────────┴──────────────┐
                │ YES                        │ NO
                ▼                            ▼
        ┌─────────────────┐        ┌──────────────────┐
        │ RESTORE SESSION │        │ SHOW LOGIN SCREEN│
        │ isLoggedIn=true │        │ User must login  │
        │ Load user data  │        └──────────────────┘
        │ Token ready for │
        │ next API call   │
        └─────────────────┘
```

---

## 4. Logout & Cleanup Flow

```
                    LOGOUT BUTTON TAPPED
                            │
                            ▼
                    ┌─────────────────────┐
                    │ AuthController      │
                    │ .logout()           │
                    └─────────┬───────────┘
                              │
                    ┌─────────┴──────────┐
                    │                    │
                    ▼                    ▼
        ┌──────────────────────┐  ┌────────────────────┐
        │ ApiService.logout()  │  │ Clear Local State  │
        │ POST /api/logout     │  │ _currentUser=null  │
        │                      │  │ _isLoggedIn=false  │
        └──────────┬───────────┘  └────────┬───────────┘
                   │                       │
                   ▼                       ▼
        ┌──────────────────────┐  ┌────────────────────┐
        │ _client.clearTokens()│  │ storage.remove()   │
        └──────────┬───────────┘  │ 'isLoggedIn'       │
                   │               │ 'user_data'        │
                   ▼               └────────┬───────────┘
        ┌──────────────────────────────────▼────┐
        │  GetStorage Cleanup                   │
        ├──────────────────────────────────────┤
        │  X auth_token        (REMOVED)       │
        │  X refresh_token     (REMOVED)       │
        │  X user_data         (REMOVED)       │
        └─────────────────────┬────────────────┘
                              │
                              ▼
                    ┌─────────────────────┐
                    │ ✅ LOGOUT COMPLETE  │
                    │ Session Cleared     │
                    │ User Logged Out     │
                    └─────────┬───────────┘
                              │
                              ▼
                    ┌─────────────────────┐
                    │ Show Login Screen   │
                    │ User must login     │
                    │ again               │
                    └─────────────────────┘
```

---

## 5. 401 Error Handling (Token Expired)

```
                    API REQUEST WITH TOKEN
                            │
                            ▼
        ┌────────────────────────────────────┐
        │ GET /api/songs                     │
        │ Authorization: Bearer 2|xyz..      │
        │                                    │
        │ (Token is expired on server)       │
        └────────────┬─────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────┐
        │ ❌ SERVER RESPONSE: 401             │
        │ Unauthorized                       │
        │ "Token has expired"                │
        └────────────┬─────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────┐
        │ ApiClient._handleResponse()        │
        │                                    │
        │ if (statusCode == 401) {           │
        └────────────┬─────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────┐
        │ clearTokens()                      │
        │                                    │
        │ _storage.remove('auth_token')      │
        │ _storage.remove('refresh_token')   │
        │ _storage.remove('user_data')       │
        └────────────┬─────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────┐
        │ throw UnauthorizedException()      │
        └────────────┬─────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────┐
        │ ✅ AUTOMATIC LOGOUT TRIGGERED      │
        │ • Session ended                    │
        │ • Token removed from device        │
        │ • User state reset                 │
        └────────────┬─────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────┐
        │ User redirected to Login Screen    │
        │ "Your session expired, login again"│
        └────────────────────────────────────┘
```

---

## 6. Storage Layers

```
┌─────────────────────────────────────────────────────────────┐
│                      APPLICATION                            │
│              (Screens, Controllers, Widgets)                │
└──────────────────────────┬──────────────────────────────────┘
                           │
        ┌──────────────────┴──────────────────┐
        │                                     │
        ▼                                     ▼
┌─────────────────────┐             ┌──────────────────────┐
│   AuthController    │             │   ApiService         │
│                     │             │                      │
│ • _currentUser      │             │ • login()            │
│ • _isLoggedIn       │             │ • logout()           │
│ • _storage (Get)    │             │ • register()         │
└──────────┬──────────┘             └──────────┬───────────┘
           │                                   │
           └───────────────┬───────────────────┘
                           │
                           ▼
                   ┌─────────────────────┐
                   │    ApiClient        │
                   │                     │
                   │ authToken (getter)  │
                   │ authToken (setter)  │
                   │ refreshToken        │
                   │ _headers            │
                   │ clearTokens()       │
                   └──────────┬──────────┘
                              │
                              ▼
                   ┌─────────────────────┐
                   │  GetStorage         │
                   │  (Wrapper)          │
                   │                     │
                   │ .read('auth_token') │
                   │ .write(key, value)  │
                   │ .remove(key)        │
                   └──────────┬──────────┘
                              │
        ┌─────────────────────┴──────────────────┐
        │                                        │
        ▼                                        ▼
   ┌────────────────────────┐      ┌────────────────────────┐
   │  ANDROID               │      │  iOS                   │
   │  SharedPreferences     │      │  NSUserDefaults        │
   │                        │      │                        │
   │  /data/data/com...     │      │  Library/Preferences/  │
   │  /shared_prefs/        │      │  flutter.music_app...  │
   │  get_storage.xml       │      │  .plist                │
   └────────────────────────┘      └────────────────────────┘
        │                                   │
        └─────────────────┬─────────────────┘
                          │
                          ▼
            ┌──────────────────────────┐
            │  DEVICE PERSISTENT      │
            │  STORAGE                │
            │                          │
            │  Survives:              │
            │  • App closure          │
            │  • System restart       │
            │  • Phone restart        │
            │                          │
            │  Key-Value Pairs:       │
            │  • auth_token: value    │
            │  • refresh_token: value │
            │  • user_data: value     │
            │  • isLoggedIn: bool     │
            └──────────────────────────┘
```

---

## 7. Header Building Process

```
Every API Request:
        │
        ▼
┌──────────────────────────┐
│ ApiClient._request()     │
│                          │
│ Get _headers property    │
└──────────┬───────────────┘
           │
           ▼
    ┌────────────────────────────────┐
    │ Map<String, String> _headers = │
    │ {                              │
    │   'Content-Type':              │
    │   'application/json',          │
    │   'Accept': 'application/json' │
    │ }                              │
    └──────────┬─────────────────────┘
               │
               ▼
    ┌────────────────────────────────┐
    │ if (authToken != null) {        │
    │   headers['Authorization'] =   │
    │   'Bearer $authToken'          │
    │ }                              │
    └──────────┬─────────────────────┘
               │
               ▼
    ┌────────────────────────────────┐
    │ Final Headers:                 │
    │ {                              │
    │   'Content-Type':              │
    │   'application/json',          │
    │   'Accept': 'application/json',│
    │   'Authorization':             │
    │   'Bearer 2|xyz789abc...'      │
    │ }                              │
    └──────────┬─────────────────────┘
               │
               ▼
        Send with request
```

---

## 8. Decision Tree: Is Token Valid?

```
                    API REQUEST RECEIVED
                            │
                            ▼
            ┌───────────────────────────┐
            │ Check authToken != null   │
            └───────────────┬───────────┘
                            │
            ┌───────────────┴───────────┐
            │                           │
        NULL                        NOT NULL
            │                           │
            ▼                           ▼
        No header              Add to header
        'Authorization'      'Authorization:
         required                Bearer $token'
            │                           │
            ▼                           ▼
        Continue          ┌────────────────────┐
        (public API)      │ Send Request with  │
                          │ token              │
                          └────────┬───────────┘
                                   │
                                   ▼
                          ┌────────────────────┐
                          │ Server validates   │
                          │ token              │
                          └────────┬───────────┘
                                   │
                    ┌──────────────┴──────────────┐
                    │                             │
                  VALID                       INVALID/EXPIRED
                    │                             │
                    ▼                             ▼
            ┌──────────────┐             ┌──────────────────┐
            │ 200 OK       │             │ 401 Unauthorized │
            │ Return data  │             │ Clear tokens     │
            │ Success ✅   │             │ Logout ❌        │
            └──────────────┘             └──────────────────┘
```

---

## 9. Storage Comparison

```
                    VOLATILE MEMORY          PERSISTENT STORAGE
                   (Lost on App Close)       (Survives App Close)
                            │                         │
        ┌───────────────────┴────────────────────┐
        │                                        │
        ▼                                        ▼
    ┌────────────┐                        ┌──────────────┐
    │ Variables: │                        │ GetStorage:  │
    │            │                        │              │
    │ • token    │                        │ • auth_token │
    │  (String)  │                        │ • refresh_.. │
    │ • user     │                        │ • user_data  │
    │  (User)    │                        │ • isLoggedIn │
    │ • isLoggedIn
                       │                        │
    │  (bool)    │                        ├──────────────┤
    └────────────┘                        │ Stored in:   │
                                          │ SharedPref.  │
         Exists only in                   │ (Android)    │
         current session                  │              │
                                          │ UserDefaults │
         Lost when:                       │ (iOS)        │
         • App closed ❌                  │              │
         • Process killed ❌              │ Survives:    │
         • Phone restarted ❌             │ • App close ✅
                                          │ • Process kill
                                          │ • Phone restart
                                          │ • Force close
                                          └──────────────┘
```

---

## 10. Complete System Overview

```
┌────────────────────────────────────────────────────────────────────┐
│                        MUSIC APP TOKEN SYSTEM                      │
└────────────────────────────────────────────────────────────────────┘

                         USER INTERACTION LAYER
    ┌─────────────────┐          ┌──────────────┐         ┌──────────┐
    │  Sign In Screen │          │  Main Screen │         │ Settings │
    └────────┬────────┘          └──────────────┘         └──────────┘
             │
             ▼
    ┌──────────────────────────────────────────────────────────────────┐
    │              BUSINESS LOGIC LAYER (Controllers)                  │
    │  AuthController: manage auth state, login/logout logic          │
    └──────────┬───────────────────────────────────────────────────────┘
               │
               ▼
    ┌──────────────────────────────────────────────────────────────────┐
    │            SERVICE LAYER (ApiService)                           │
    │  • login() - extract token from response                        │
    │  • logout() - clear tokens                                      │
    │  • getSongs() - use token in requests                           │
    └──────────┬───────────────────────────────────────────────────────┘
               │
               ▼
    ┌──────────────────────────────────────────────────────────────────┐
    │        HTTP CLIENT LAYER (ApiClient)                            │
    │  • Store token: authToken getter/setter                         │
    │  • Build headers: include 'Authorization' with token            │
    │  • Handle errors: 401 → clearTokens()                          │
    │  • Make requests: GET/POST/PUT/DELETE with headers             │
    └──────────┬───────────────────────────────────────────────────────┘
               │
               ▼
    ┌──────────────────────────────────────────────────────────────────┐
    │      STORAGE LAYER (GetStorage wrapper)                         │
    │  • read('auth_token') - retrieve token                         │
    │  • write('auth_token', token) - save token                     │
    │  • remove('auth_token') - delete token                         │
    └──────────┬───────────────────────────────────────────────────────┘
               │
               ▼
    ┌──────────────────────────────────────────────────────────────────┐
    │    DEVICE STORAGE LAYER (SharedPrefs / UserDefaults)           │
    │  Android: SharedPreferences                                     │
    │  iOS: UserDefaults                                              │
    │  Data: Key-value pairs persisted to device                     │
    └──────────────────────────────────────────────────────────────────┘
```

---

## Summary

All diagrams show:
✅ Token extraction from server
✅ Token storage in GetStorage
✅ Token persistence to device
✅ Token usage in requests
✅ Session recovery on restart
✅ Logout cleanup
✅ 401 error handling
✅ Multi-layer architecture
✅ Proper data flow
✅ State management

**All systems working correctly!**
