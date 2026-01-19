# Quick Reference - Profile Feature

## 📱 User Screens

### Account Screen (Tab 4)
```
┌─────────────────────────────────┐
│  [⬅] My Account      [📡 offline]│
├─────────────────────────────────┤
│         [Profile Image]         │
│     (User Icon if no image)     │
│                                 │
│      John Doe (fullName)        │
│      john@example.com           │
│      +1234567890                │
│      [⭐ Premium Badge]         │
│                                 │
│    [  Edit Profile Button ]     │
├─────────────────────────────────┤
│ 📥 Downloaded Songs   [→]       │
│ ❓ Help Center         [→]       │
│ 🚪 Logout             [→]       │
└─────────────────────────────────┘
```

### Edit Profile Screen
```
┌─────────────────────────────────┐
│  [⬅] Edit Profile              │
├─────────────────────────────────┤
│         [Profile Image]         │
│      [📷 Camera Icon] (upload)  │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ Full Name                   │ │
│ │ ┌───────────────────────┐   │ │
│ │ │ John Doe            │   │ │
│ │ └───────────────────────┘   │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ Email (read-only)           │ │
│ │ ┌───────────────────────┐   │ │
│ │ │ john@example.com    │   │ │
│ │ └───────────────────────┘   │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ Phone Number                │ │
│ │ ┌───────────────────────┐   │ │
│ │ │ +1234567890         │   │ │
│ │ └───────────────────────┘   │ │
│ └─────────────────────────────┘ │
│                                 │
│  [  Edit Profile Button  ]      │
│   OR                            │
│  [  Cancel ]  [ Save Changes ]  │
└─────────────────────────────────┘
```

## 🔄 State Transitions

### Profile Image States
```
Default State
    ↓ (User clicks camera)
Image Picker
    ↓ (Image selected)
Uploading State (spinner)
    ↓
Success ← API responds
    ↓ (Snackbar "Success!")
Updated UI
```

### Profile Form States
```
Display State (read-only)
    ↓ (User clicks "Edit Profile")
Edit Mode (fields enabled)
    ↓ (User edits & clicks "Save")
Saving State (loading spinner)
    ↓
Success ← API responds
    ↓ (Snackbar "Success!")
Display Mode (read-only again)
```

## 🔌 API Calls

### Get Profile
```dart
// Called automatically when opening account screen
final response = await _apiService.getProfile();
// Response: User object with all fields
```

### Update Profile
```dart
// Called when user clicks "Save Changes"
final response = await _apiService.updateProfile(
  name: "New Name",
  phone: "+999999999"
);
// Response: Updated User object
```

### Upload Image
```dart
// Called automatically after image selection
final response = await _apiService.uploadProfileImage(imagePath);
// Response: Updated User object with new profile_image URL
```

## 📊 Data Binding

### Account Screen
```dart
Obx(() {
  final user = _authController.currentUser;
  // Automatically rebuilds when currentUser changes
  return Column(children: [
    Text(user?.fullName ?? 'Guest'),
    Text(user?.email ?? ''),
    // ... more fields
  ]);
})
```

### Profile Form
```dart
// Form initializes with current user data
void _initializeControllers() {
  final user = _authController.currentUser;
  _nameController = TextEditingController(text: user?.fullName ?? '');
  _phoneController = TextEditingController(text: user?.phone ?? '');
}
```

### Profile Image
```dart
Obx(() {
  final user = _authController.currentUser;
  // Shows server image or newly selected image
  return Container(
    image: DecorationImage(image: networkImage OR fileImage)
  );
})
```

## 🎨 UI Components

### Profile Image Widget
- Size: 120x120 circular with border
- Icon fallback: Icons.person (50x50)
- Camera button: 20x20 in bottom-right corner
- Border color: AppColors.primaryColor

### Custom Text Field
- Label color: white (enabled) or white54 (disabled)
- Border radius: 12
- States: enabled, disabled, focused
- Icons: prefix icon support

### Buttons
- Edit Profile: Outlined button
- Save Changes: Elevated (primaryColor background)
- Cancel: Outlined button

## 🔐 Field States

### Profile Form Fields
```
Full Name:     [Editable]   [Required]
Email:         [Read-only]  [Disabled]
Phone:         [Editable]   [Optional]
```

## ⚙️ Configuration

### Update API Endpoints
File: `lib/core/api/api_config.dart`
```dart
static const String profile = '/me';
static const String updateProfile = '/update-profile';
static const String uploadProfileImage = '/upload-profile';
```

### Image Compression Settings
File: `lib/widgets/profile_image.dart` (line 256)
```dart
maxWidth: 800,
maxHeight: 800,
imageQuality: 80,
```

## 📝 Error Messages

| Scenario | Message | Action |
|----------|---------|--------|
| Image upload fails | "Failed to upload image" | Reset, retry |
| Profile save fails | "Failed to update profile" | Show error, retry |
| Empty name | "Name cannot be empty" | Validate input |
| Network error | Shows in snackbar | Retry when online |

## 🔄 Data Flow Summary

```
User Opens Account Screen
    ↓
Load from AuthController.currentUser
    ↓
Display Profile Info

User Clicks "Edit Profile"
    ↓
Navigate to Edit Screen
    ↓
Initialize Form with Current Data
    ↓
User Edits Form/Image
    ↓
User Clicks Save
    ↓
Send to API
    ↓
Update AuthController
    ↓
UI Updates (via Obx)
    ↓
Return to Display Mode
```

## 🛠️ Troubleshooting Quick Fixes

| Problem | Solution |
|---------|----------|
| Profile not showing | Check if login was successful |
| Image not uploading | Verify uploadProfileImage endpoint |
| Form not saving | Check updateProfile endpoint |
| UI not updating | Verify AuthController.updateCurrentUser() called |
| Build stuck | Run: `flutter clean && flutter pub get` |

---

**All code is production-ready! ✅**
