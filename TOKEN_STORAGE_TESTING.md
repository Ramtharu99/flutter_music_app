# Token Storage Testing Guide

## How to Verify Token Storage is Working

### Test 1: Verify Token is Stored After Login ✅

#### Step 1: Add Debug Output
Edit [lib/controllers/auth_controller.dart](lib/controllers/auth_controller.dart) and add this to the `login()` method:

```dart
if (response.success && response.data != null) {
  _currentUser.value = response.data;
  _isLoggedIn.value = true;
  _storage.write('isLoggedIn', true);

  await _offlineStorage.saveUser(response.data!);

  // 🔍 DEBUG: Print stored token
  final apiService = ApiService();
  debugPrint('✅ LOGIN SUCCESS');
  debugPrint('Token: ${apiService.authToken}');
  debugPrint('Is Authenticated: ${apiService.isAuthenticated}');
  
  return true;
}
```

#### Expected Output:
```
✅ LOGIN SUCCESS
Token: 2|xyz789abc012def345ghi678jkl901mno234pqr567stu890
Is Authenticated: true
```

---

### Test 2: Verify Token is Used in API Requests ✅

#### Step 1: Check Network Request Headers
Run the app and look at the Flutter console logs:

```
┌──────────────────────────────────────────
│ API REQUEST
│ GET: https://music-api.free.nf/api/songs
│ Headers: {
│   Content-Type: application/json,
│   Accept: application/json,
│   Authorization: Bearer 2|xyz789...  ← TOKEN PRESENT ✅
│ }
└──────────────────────────────────────────
```

#### Expected Result:
The `Authorization: Bearer <token>` header should be present in all API requests after login.

---

### Test 3: Verify Token Persists on App Restart ✅

#### Steps:
1. Run the app
2. Login with credentials
3. See "✅ LOGIN SUCCESS" in console
4. Close the app completely (kill the process)
5. Reopen the app
6. Check the console output

#### Expected Result:
```
📱 Auth State Loaded:
   - First Time: false
   - Logged In: true  ← Still logged in! ✅
   - User: john@example.com
```

The user should be automatically logged in without needing to enter credentials again.

---

### Test 4: Verify Token is Cleared on Logout ✅

#### Steps:
1. Login successfully
2. Call logout
3. Check storage

#### Add Debug Output to [lib/controllers/auth_controller.dart](lib/controllers/auth_controller.dart):

```dart
Future<void> logout() async {
  _isLoading.value = true;

  try {
    await _apiService.logout();
  } catch (_) {
    // Ignore API errors on logout
  }

  // Clear local state
  _currentUser.value = null;
  _isLoggedIn.value = false;
  _storage.write('isLoggedIn', false);
  await _offlineStorage.clearUser();

  // 🔍 DEBUG: Print logout confirmation
  debugPrint('✅ LOGOUT SUCCESS');
  debugPrint('Token cleared: ${_apiService.authToken ?? 'null'}');
  debugPrint('Is Authenticated: ${_apiService.isAuthenticated}');

  _isLoading.value = false;
  debugPrint('Logged out');
}
```

#### Expected Output:
```
✅ LOGOUT SUCCESS
Token cleared: null
Is Authenticated: false
Logged out
```

---

### Test 5: Verify Token Handling on 401 Error ✅

#### How to Simulate:
1. Login successfully
2. Get the token from console
3. Modify the token manually (cut it short)
4. Try to make an API request

#### Add Debug to [lib/core/api/api_client.dart](lib/core/api/api_client.dart) in `_handleResponse()`:

```dart
case 401:
  debugPrint('⚠️ TOKEN EXPIRED OR INVALID (401)');
  debugPrint('Clearing token...');
  clearTokens();
  debugPrint('Token after clear: ${authToken ?? 'null'}');
  throw UnauthorizedException(message);
```

#### Expected Output:
```
⚠️ TOKEN EXPIRED OR INVALID (401)
Clearing token...
Token after clear: null
```

---

### Test 6: Manual Storage Inspection

#### Android (Using ADB):
```bash
# Connect device with USB debugging enabled
adb shell
cd /data/data/com.example.music_app/shared_prefs/
cat get_storage.xml

# You should see:
# <string name="auth_token">2|xyz789abc012def345...</string>
# <boolean name="isLoggedIn">true</boolean>
```

#### iOS (Using Xcode):
1. Open Xcode
2. Window → Devices and Simulators
3. Select your simulator
4. ApplicationSupport → music_app
5. Library → Preferences → flutter.music_app.plist
6. Look for keys: `auth_token`, `refresh_token`, `isLoggedIn`

#### Using Flutter DevTools:
```bash
# Terminal
flutter pub global activate devtools
devtools

# Then open DevTools in browser and check Storage tab
```

---

### Test 7: Token Refresh Scenario ✅

If your server supports refresh tokens:

#### Check if refresh token is stored:
```dart
// In ApiService login method
debugPrint('Refresh Token: ${_client.refreshToken}');
```

Expected output:
```
Refresh Token: 2|refresh...
```

---

### Test 8: Offline Login ✅

#### Steps:
1. Login while online
2. Turn off internet/WiFi
3. Close and reopen app
4. Try to access saved user data

#### Expected Result:
```
📱 Auth State Loaded:
   - First Time: false
   - Logged In: true
   - User: john@example.com  ← User data persisted ✅
```

User remains logged in with offline data.

---

### Test 9: Complete Flow Test

#### Scenario: Full Login → API Request → Logout → Login Again

```dart
// Test Console Output Check List:

// 1️⃣ First Login
✅ LOGIN SUCCESS
Token: 2|xyz789abc012def345...
Is Authenticated: true

// 2️⃣ API Request
┌──────────────────────────────────────────
│ API REQUEST
│ GET: https://music-api.free.nf/api/songs
│ Authorization: Bearer 2|xyz789...  ✅
└──────────────────────────────────────────

// 3️⃣ API Response
┌──────────────────────────────────────────
│ ✅ API RESPONSE
│ Status: 200
└──────────────────────────────────────────

// 4️⃣ Logout
✅ LOGOUT SUCCESS
Token cleared: null
Is Authenticated: false

// 5️⃣ Second Login
✅ LOGIN SUCCESS
Token: 2|xyz789abc012def345...
Is Authenticated: true
```

---

## Debugging Checklist

If token storage is NOT working, check these:

### ❌ Token not storing?
- [ ] Is `get_storage: ^2.1.1` in pubspec.yaml?
- [ ] Did you run `flutter pub get`?
- [ ] Is `authToken` setter being called in ApiService.login()?
- [ ] Check: `if (response.data!['token'] != null) { _client.authToken = response.data!['token']; }`

### ❌ Token not in API requests?
- [ ] Check if token is null: `if (authToken != null)`
- [ ] Check Authorization header format: `'Bearer $authToken'`
- [ ] Verify _headers method is called in _request method
- [ ] Check HTTP method (GET, POST, PUT, DELETE) all use _headers

### ❌ Token not persisting after restart?
- [ ] Check `_loadInitialState()` in AuthController
- [ ] Verify `_storage.read('isLoggedIn')` is being called
- [ ] Check `_offlineStorage.getUser()` is working
- [ ] Ensure app is fully closed (not just backgrounded)

### ❌ 401 errors after login?
- [ ] Verify server is returning token in correct format
- [ ] Check token key in response matches `response.data!['token']`
- [ ] Verify Bearer prefix is correct: `'Bearer $token'` (not 'Bearer: token')
- [ ] Check if token has expired on server

---

## Quick Debug Commands

Add these to any screen for quick testing:

```dart
// Check if token exists
import 'package:music_app/services/api_service.dart';

final apiService = ApiService();
debugPrint('Current Token: ${apiService.authToken}');
debugPrint('Is Auth: ${apiService.isAuthenticated}');

// In any controller:
final authController = Get.find<AuthController>();
debugPrint('User: ${authController.currentUser?.email}');
debugPrint('Logged In: ${authController.isLoggedIn}');
```

---

## Network Monitoring

### Using Charles/Fiddler Proxy
1. Set your device to use proxy
2. Monitor all requests
3. Check Authorization header is present
4. Verify Bearer token format

Expected header:
```
Authorization: Bearer 2|xyz789abc012def345ghi678jkl901mno234pqr567stu890
```

### Using Flutter DevTools
```bash
devtools
# Open in browser → Network tab
# Filter by "songs" or API endpoint
# Click request → Headers → check Authorization
```

---

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Token not stored | Check response has `data['token']` field |
| Token is null after restart | Ensure logout() doesn't call `_storage.write('isLoggedIn', false)` before saving user |
| 401 errors on requests | Token might be expired - check if refresh token logic needed |
| Headers not showing token | Check if token is null - add null check |
| Multiple login attempts | Ensure previous token is cleared or overwritten |
| Offline login fails | Ensure user data is saved with `_offlineStorage.saveUser()` |

---

## Token Storage Validation Checklist

After implementing and testing, verify:

- [ ] Token extracted from login response
- [ ] Token stored in GetStorage
- [ ] Token persisted after app restart
- [ ] Token included in Authorization header
- [ ] Token cleared on logout
- [ ] Token cleared on 401 error
- [ ] Refresh token stored (if applicable)
- [ ] User data cached for offline access
- [ ] Session restored on app launch
- [ ] All API requests include token automatically

✅ If all checks pass, token storage is working perfectly!
