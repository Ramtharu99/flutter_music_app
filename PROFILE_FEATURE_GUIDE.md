# Profile Feature Implementation Guide

## Overview
This guide explains the complete profile display, editing, and image upload functionality implemented in your music app.

---

## Flow Diagram

### User Information Display Flow
```
Account Screen
    ↓
Displays user data from AuthController.currentUser
    ↓
Shows: Name, Email, Phone, Profile Image, Premium Badge, Join Date
    ↓
User clicks "Edit Profile" button → Opens EditProfileScreen
```

### Profile Editing Flow
```
Edit Profile Screen
    ↓
ProfileImage Widget (Image Upload)     ProfileForm Widget (Text Data)
    ↓                                          ↓
User picks image from camera/gallery    User edits name/phone fields
    ↓                                          ↓
uploadProfileImage() API call            Click "Edit" mode → enables fields
    ↓                                          ↓
Updates AuthController.currentUser       Click "Save Changes"
    ↓                                          ↓
                                         updateProfile() API call
                                         ↓
                                   Updates AuthController.currentUser
```

---

## File Structure

### Core Components

#### 1. **Account Screen** (`lib/screens/account_screen.dart`)
- Displays current user information
- Shows profile image with fallback to user icon
- Displays user details: name, email, phone, join date
- Shows Premium badge if applicable
- "Edit Profile" button redirects to EditProfileScreen
- Includes logout functionality

**Key Features:**
- Real-time data binding using `Obx()` from GetX
- Automatic UI updates when user data changes
- Formatted date display using `_formatDate()` helper
- Network image loading for profile pictures

#### 2. **Edit Profile Screen** (`lib/screens/edit_profile_screen.dart`)
- Container for ProfileImage and ProfileForm widgets
- Refresh capability
- Offline/Online indicator

#### 3. **Profile Image Widget** (`lib/widgets/profile_image.dart`)
- Displays user's current profile picture
- Camera icon for image selection
- Image picker with camera/gallery options
- Automatic image upload after selection
- Loading indicator during upload
- Real-time UI updates

**Key Methods:**
```dart
_pickImage(ImageSource source)     // Select image from camera or gallery
_uploadProfileImage(String path)   // Upload to server
_showImagePickerBottomSheet()      // Show selection options
```

#### 4. **Profile Form Widget** (`lib/widgets/profile_form.dart`)
- Displays user information fields
- Edit mode toggle
- Form validation
- API integration for profile updates

**Features:**
- Name field: editable
- Email field: read-only (for security)
- Phone field: editable
- Edit/Save/Cancel button modes
- Loading state during submission
- Error handling with snackbars

#### 5. **Custom Text Field** (`lib/widgets/custom_text_field.dart`)
- Reusable text input widget
- Support for enabled/disabled states
- Password field support
- Icon support
- Validation support

**Updated with:**
```dart
final bool enabled;  // Controls if field is editable
```

---

## API Integration

### API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/me` | GET | Get current user profile |
| `/update-profile` | PUT | Update user profile (name, phone) |
| `/upload-profile` | POST | Upload profile image (multipart) |

### API Service Methods

#### 1. `getProfile()`
```dart
Future<ApiResponse<User>> getProfile()
```
Fetches current user data from `/me` endpoint.

#### 2. `getUserById(String userId)`
```dart
Future<ApiResponse<User>> getUserById(String userId)
```
Fetches specific user data by ID.

#### 3. `updateProfile({...})`
```dart
Future<ApiResponse<User>> updateProfile({
  String? name,
  String? phone,
})
```
Updates user profile with new data. Calls `/update-profile` endpoint.

#### 4. `uploadProfileImage(String imagePath)`
```dart
Future<ApiResponse<User>> uploadProfileImage(String imagePath)
```
Uploads profile image to server. Uses multipart/form-data.

### API Client Enhancement

The `ApiClient` now includes:
```dart
Future<ApiResponse<T>> uploadFile<T>(
  String endpoint,
  String filePath,
  {
    String fileFieldName = 'file',
    Map<String, String>? additionalFields,
    T Function(dynamic json)? parser,
  }
)
```

This method handles:
- Multipart file uploads
- Additional form fields
- Progress tracking capability
- Automatic error handling

---

## Data Models

### User Model (`lib/models/user_model.dart`)
```dart
class User {
  final String id;
  final String email;
  final String? name;
  final String? profileImage;
  final String? phone;
  final bool isPremium;
  final DateTime? createdAt;
  
  String get fullName { /* returns name or email prefix */ }
}
```

**API Response Format:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+1234567890",
    "profile_image": "https://music-api.free.nf/storage/profiles/image.jpg",
    "created_at": "2025-01-13T10:00:00.000000Z",
    "updated_at": "2025-01-13T10:00:00.000000Z"
  }
}
```

---

## State Management

### AuthController (`lib/controllers/auth_controller.dart`)

**Observable Variables:**
```dart
final Rxn<User> _currentUser = Rxn<User>();  // Current logged-in user
```

**Key Methods:**
```dart
User? get currentUser => _currentUser.value;

void updateCurrentUser(User user) {
  _currentUser.value = user;
  _offlineStorage.saveUser(user);  // Persist locally
}

void updateLocalUser(User user) {
  // Alias for updateCurrentUser
}
```

**Features:**
- Reactive updates using GetX `Obx()`
- Automatic local persistence
- Offline support

---

## User Flow

### 1. Viewing Profile
```
Account Screen (Tab 4)
    ↓
Displays current user info from AuthController
    ↓
Shows profile picture, name, email, phone, join date
    ↓
All data updates automatically when AuthController.currentUser changes
```

### 2. Editing Profile
```
Click "Edit Profile" button
    ↓
Navigate to Edit Profile Screen
    ↓
Two sections:
    a) Profile Image (top) - can change image
    b) Form (bottom) - can edit name/phone
    ↓
Changes NOT sent to server until explicit "Save" click
```

### 3. Changing Profile Image
```
Click camera icon on profile image
    ↓
Bottom sheet appears with options:
    - Take Photo (uses device camera)
    - Choose from Gallery (opens gallery picker)
    ↓
Image selected
    ↓
Automatic upload to /upload-profile endpoint
    ↓
Loading indicator shows during upload
    ↓
Success/Error snackbar displayed
    ↓
Profile image updates automatically
```

### 4. Updating Profile Information
```
Click "Edit Profile" button (in form area)
    ↓
Name & Phone fields become editable
    ↓
Email field remains read-only
    ↓
Edit desired fields
    ↓
Click "Save Changes"
    ↓
Validation checks
    ↓
PUT request to /update-profile with updated data
    ↓
Loading indicator during submission
    ↓
Response received
    ↓
AuthController.updateCurrentUser() called
    ↓
UI updates automatically
    ↓
Success snackbar shown
    ↓
Form exits edit mode
```

---

## Key Implementation Details

### 1. Image Display Logic
```dart
// Determine which image to show
final imageProvider = _imageFile != null
    ? FileImage(_imageFile!)  // Newly selected image
    : (user?.profileImage != null && user!.profileImage!.isNotEmpty)
        ? NetworkImage(user.profileImage!)  // Server image
        : null;  // Show icon as fallback

// If no image, show user icon
child: imageProvider == null
    ? Icon(Icons.person, size: 50)
    : null
```

### 2. Form Initialization
```dart
void _initializeControllers() {
  final user = _authController.currentUser;
  _nameController = TextEditingController(text: user?.fullName ?? '');
  _emailController = TextEditingController(text: user?.email ?? '');
  _phoneController = TextEditingController(text: user?.phone ?? '');
}
```

### 3. Reactive UI Updates
```dart
Obx(() {
  final user = _authController.currentUser;
  // Widget rebuilds automatically when currentUser changes
  return Text(user?.fullName ?? 'Guest');
})
```

### 4. Image Upload with Auto-refresh
```dart
Future<void> _uploadProfileImage(String imagePath) async {
  setState(() => _isUploading = true);
  
  try {
    final response = await _apiService.uploadProfileImage(imagePath);
    if (response.success && response.data != null) {
      // Update auth controller - triggers UI rebuild
      _authController.updateCurrentUser(response.data!);
    }
  } finally {
    setState(() => _isUploading = false);
  }
}
```

---

## Error Handling

### Image Upload Errors
```dart
// If upload fails, display error snackbar
Get.snackbar(
  'Error',
  'Failed to upload image: $error',
  backgroundColor: Colors.red,
  colorText: Colors.white,
);

// Reset UI
setState(() { _imageFile = null; });
```

### Form Submission Errors
```dart
// Validation
if (_nameController.text.isEmpty) {
  Get.snackbar('Error', 'Name cannot be empty');
  return;
}

// API errors
if (!response.success) {
  Get.snackbar('Error', response.message ?? 'Failed to update profile');
}
```

---

## Offline Support

All user data is persisted locally:
```dart
await _offlineStorage.saveUser(user);  // Called after any update
```

This allows:
- Viewing user profile when offline
- Showing last known profile picture
- Supporting offline access to account info

---

## Customization Guide

### Change Image Upload Endpoint
In `lib/core/api/api_config.dart`:
```dart
static const String uploadProfileImage = '/your-endpoint-here';
```

### Change Update Profile Endpoint
In `lib/core/api/api_config.dart`:
```dart
static const String updateProfile = '/your-endpoint-here';
```

### Add More Profile Fields
1. Update `User` model to include new fields
2. Add new `TextEditingController` in ProfileForm
3. Add new `CustomTextField` in ProfileForm UI
4. Update `updateProfile()` call in `_saveProfile()`

### Customize Profile Picture Size
In `lib/widgets/profile_image.dart`:
```dart
Container(
  width: 120,  // Change this
  height: 120, // and this
  ...
)
```

---

## Testing Checklist

- [ ] Profile image displays correctly
- [ ] User icon shows when no image
- [ ] Camera icon is clickable
- [ ] Image picker works (camera & gallery)
- [ ] Image uploads successfully
- [ ] Profile info shows in account screen
- [ ] Edit button navigates to edit screen
- [ ] Form fields populate with initial values
- [ ] Edit mode enables/disables fields correctly
- [ ] Save changes updates profile
- [ ] Snackbars show for success/errors
- [ ] Offline mode shows last known data
- [ ] Phone number displays when available
- [ ] Premium badge shows correctly
- [ ] Join date formats properly

---

## Common Issues & Solutions

### Image Not Showing After Upload
- Ensure server returns updated `profile_image` URL in response
- Check URL is accessible and not blocked by CORS

### Form Not Saving Changes
- Verify `/update-profile` endpoint exists and is correct
- Check API returns user data in response
- Ensure AuthController receives update

### Profile Not Showing Initial Values
- Verify `currentUser` is loaded in AuthController
- Check `User.fromJson()` correctly parses API response
- Ensure `_initializeControllers()` called in `initState()`

---

## Summary

The profile feature provides a complete user profile management system with:
- ✅ Real-time profile display
- ✅ Image upload and management
- ✅ Profile information editing
- ✅ Proper error handling
- ✅ Offline support
- ✅ Responsive UI updates
- ✅ User-friendly feedback

All components work together seamlessly using GetX state management and reactive programming patterns.
