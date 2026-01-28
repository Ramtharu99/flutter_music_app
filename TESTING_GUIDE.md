# 🧪 Step-by-Step Testing Guide

## Pre-Test Setup

### 1. Build the Project
```bash
# Clean previous builds
flutter clean

# Get all dependencies
flutter pub get

# Verify no errors
flutter analyze
```

**Expected Result:** ✅ No errors or warnings in modified files

---

## Test 1: Video Player Functionality

### Step 1.1 - Launch Video Player
1. Run the app: `flutter run`
2. Navigate to video player screen
3. Verify video loads and displays

**Expected Result:** ✅ Video appears in center with aspect ratio preserved

### Step 1.2 - Test Play/Pause
1. Video should start playing automatically
2. Tap center of screen → Play/Pause button appears
3. Tap play button → Video pauses
4. Tap play button again → Video resumes

**Expected Result:** ✅ Video pauses and resumes correctly

### Step 1.3 - Test Forward/Rewind
1. Controls visible on screen
2. Tap rewind button (⏪) → Video seeks back 10s
3. Verify progress bar moves left
4. Tap forward button (⏩) → Video seeks forward 10s
5. Verify progress bar moves right

**Expected Result:** ✅ ±10s seeking works smoothly

### Step 1.4 - Test Progress Bar Seeking
1. Tap anywhere on progress bar
2. Video should seek to that position
3. Drag progress bar scrubber left/right
4. Video should seek smoothly

**Expected Result:** ✅ Dragging is smooth and responsive

### Step 1.5 - Test Time Display
1. Verify current time shows on left of progress bar
2. Verify total duration shows on right
3. Check format is MM:SS (and HH:MM:SS for long videos)

**Expected Result:** ✅ Times display correctly

### Step 1.6 - Test Full-Screen Toggle
1. Tap fullscreen button in header
2. Device rotates to landscape
3. Video fills entire screen
4. Controls remain accessible

**Expected Result:** ✅ Video displays full-screen in landscape

### Step 1.7 - Test Auto-Rotation
1. Play video
2. Hold device horizontally
3. Video automatically rotates to landscape
4. Controls are visible and functional

**Expected Result:** ✅ Auto-rotation works

### Step 1.8 - Test Back Button
1. While in full-screen video
2. Press back button (Android) or swipe back
3. Device rotates back to portrait
4. Returns to previous screen

**Expected Result:** ✅ Properly exits full-screen and returns to portrait

### Step 1.9 - Test Control Auto-Hide
1. Start playing video
2. Controls should be visible
3. Wait 4 seconds without touching screen
4. Controls fade out

**Expected Result:** ✅ Controls hide after 4 seconds

### Step 1.10 - Test Control Display on Tap
1. Tap anywhere on video after controls are hidden
2. Controls reappear with animation
3. Controls hide again after 4 seconds

**Expected Result:** ✅ Controls toggle on tap

### Step 1.11 - Test Buffering Indicator
1. If video doesn't load instantly
2. Should show spinning loading indicator
3. Indicator disappears when buffered

**Expected Result:** ✅ Loading indicator appears appropriately

---

## Test 2: Download Functionality

### Step 2.1 - Download Button Visibility
1. Go to songs list
2. Verify each song has a download icon on the right
3. Icon should be visible and clickable

**Expected Result:** ✅ Download button visible on all songs

### Step 2.2 - Initiate Download
1. Tap download icon next to a song
2. Should show circular progress indicator
3. Progress indicator should show 0%
4. Progress should start updating

**Expected Result:** ✅ Download begins with progress display

### Step 2.3 - Progress Updates
1. Watch download progress
2. Should update every ~200ms
3. Progress should increment by ~5%
4. Percentage displayed in progress circle

**Expected Result:** ✅ Progress updates in real-time

### Step 2.4 - Multiple Concurrent Downloads
1. Start downloading a song
2. While first is downloading, start another
3. Both should show progress
4. Status bar shows first one

**Expected Result:** ✅ Multiple downloads supported

### Step 2.5 - Status Bar Display
1. While downloading, check bottom of screen
2. Should see blue status bar
3. Shows "Downloading" label
4. Shows song title
5. Shows percentage
6. Has close/cancel button

**Expected Result:** ✅ Status bar displays correctly

### Step 2.6 - Cancel Download from Status Bar
1. While downloading, tap cancel button (X)
2. Download should stop
3. Progress circle should disappear
4. Status bar should hide

**Expected Result:** ✅ Cancel functionality works

### Step 2.7 - Download Completion
1. Wait for download to complete (100%)
2. Should show green checkmark
3. Notification should appear
4. Song should appear in downloaded songs list

**Expected Result:** ✅ Completion handled properly

### Step 2.8 - Verify Downloaded Song Persistence
1. Go to downloaded songs (menu button)
2. Just downloaded song should appear
3. Close app completely
4. Reopen app
5. Song should still be in downloaded list

**Expected Result:** ✅ Downloads persist after app close

### Step 2.9 - Play Downloaded Song
1. From downloaded songs list
2. Tap on a song
3. Should immediately start playing
4. Should not require internet

**Expected Result:** ✅ Downloaded songs playable offline

---

## Test 3: Downloaded Songs Management

### Step 3.1 - View Downloaded Songs
1. Tap menu button in now playing screen
2. Bottom sheet should open
3. Should show "Downloaded Songs" title
4. Should list all downloaded songs

**Expected Result:** ✅ Downloaded songs list displays

### Step 3.2 - Delete Individual Song
1. In downloaded songs list
2. Tap popup menu on a song
3. Select delete option
4. Confirm deletion
5. Song should disappear from list

**Expected Result:** ✅ Delete functionality works

### Step 3.3 - Clear All Downloads
1. In downloaded songs list
2. Tap delete all button (trash icon)
3. Confirm clear all
4. All songs should disappear

**Expected Result:** ✅ Clear all works

### Step 3.4 - Song Display in List
1. Downloaded songs should show:
   - Album artwork
   - Song title
   - Artist name
   - Popup menu

**Expected Result:** ✅ All info displays correctly

---

## Test 4: Notifications

### Step 4.1 - Download Progress Notifications (Android)
1. Start a download
2. Check notification panel
3. Should show:
   - "Downloading [Song Name]"
   - Progress percentage
   - Progress bar

**Expected Result:** ✅ Notifications appear with progress

### Step 4.2 - Download Completion Notification
1. Wait for download to complete
2. Notification should change to:
   - "Download Complete"
   - "Song name is ready offline"

**Expected Result:** ✅ Completion notification appears

### Step 4.3 - Tap Notification (Optional)
1. Tap on download notification
2. Should navigate to downloaded songs

**Expected Result:** ✅ Notification is interactive

---

## Test 5: UI/UX

### Step 5.1 - Video Player Header
1. Verify header shows:
   - Back button
   - Video title
   - Fullscreen toggle

**Expected Result:** ✅ Header displays all elements

### Step 5.2 - Color Scheme
1. Verify all colors are consistent
2. Download buttons are blue
3. Completed downloads are green
4. Status bar is blue gradient

**Expected Result:** ✅ Colors are professional

### Step 5.3 - Animations
1. Tap play/pause → Should animate smoothly
2. Show/hide controls → Should fade
3. Download progress → Should rotate smoothly
4. All transitions → Should be smooth

**Expected Result:** ✅ Animations are smooth

### Step 5.4 - Responsiveness
1. During download, UI should be responsive
2. No freezing or stuttering
3. Scrolling should be smooth
4. Buttons should respond immediately

**Expected Result:** ✅ No UI lag

---

## Test 6: Memory & Performance

### Step 6.1 - Memory Baseline
1. Open Android Studio / Xcode
2. Monitor memory usage
3. Baseline memory: ~50-60MB (empty)

**Expected Result:** ✅ Reasonable baseline

### Step 6.2 - Memory During Video
1. Play video
2. Monitor memory
3. Should be ~80-100MB (video in memory)
4. Should not increase after stabilization

**Expected Result:** ✅ Memory stable during video

### Step 6.3 - Memory During Download
1. Start 5 downloads
2. Monitor memory
3. Should be ~100-120MB max
4. Should not spike

**Expected Result:** ✅ Memory controlled during downloads

### Step 6.4 - Video Playback Performance
1. Play video and monitor FPS
2. FPS should stay 30-60 stable
3. No jank or stuttering
4. Smooth seeking

**Expected Result:** ✅ Playback is smooth

### Step 6.5 - Download Performance
1. Start multiple downloads
2. Check CPU usage
3. CPU should be <25% consistently
4. UI should remain responsive

**Expected Result:** ✅ Downloads don't block UI

---

## Test 7: Navigation

### Step 7.1 - List to Video
1. From main list
2. Tap a song
3. Should navigate to now playing
4. Should not show video player (music player)

**Expected Result:** ✅ Navigation works

### Step 7.2 - List to Downloaded
1. From main list
2. Tap downloaded songs count/button
3. Should show downloaded songs sheet

**Expected Result:** ✅ Navigation to downloaded works

### Step 7.3 - Back Navigation
1. From any screen
2. Press back button
3. Should return to previous screen
4. State should be preserved (if needed)

**Expected Result:** ✅ Back navigation works

---

## Test 8: Edge Cases

### Step 8.1 - Empty Download List
1. With no downloads
2. Open downloaded songs
3. Should show empty state message
4. Icon should display

**Expected Result:** ✅ Empty state handled

### Step 8.2 - Very Long Song Title
1. A song with long title
2. Should truncate with ellipsis
3. Should not break layout
4. Tooltip shows full title

**Expected Result:** ✅ Long titles handled

### Step 8.3 - No Internet During Download
1. Start download
2. Disable internet
3. Download should continue (it's simulated)
4. Complete normally

**Expected Result:** ✅ Handles network changes

### Step 8.4 - App Background During Download
1. Start download
2. Switch app to background
3. Go back to app
4. Download should have continued
5. Progress should be updated

**Expected Result:** ✅ Background handling works

### Step 8.5 - App Crash/Restart During Download
1. Start download
2. Force stop app
3. Reopen app
4. Download history lost (app state cleared)
5. Downloaded songs list still shows completed downloads

**Expected Result:** ✅ Persistent storage works

---

## Test 9: Device-Specific Tests

### Step 9.1 - Phone Portrait Mode
1. Test all features in portrait
2. Layout should be optimal
3. All buttons clickable
4. No overlaps

**Expected Result:** ✅ Portrait layout perfect

### Step 9.2 - Phone Landscape Mode
1. Rotate to landscape
2. Layout should adjust
3. Video player should fill screen
4. Controls accessible

**Expected Result:** ✅ Landscape layout perfect

### Step 9.3 - Tablet
1. Test on tablet (if available)
2. UI should scale appropriately
3. Download list should show better
4. Video should be large

**Expected Result:** ✅ Tablet layout responsive

---

## Test 10: Final Checks

### Pre-Submission
- [ ] Run `flutter analyze` - No errors
- [ ] Check for memory leaks
- [ ] Test on Android (API 21+)
- [ ] Test on iOS (11+)
- [ ] Check permissions work
- [ ] Verify notifications send
- [ ] Check offline playback
- [ ] Monitor battery usage
- [ ] Test with slow network
- [ ] Test with no network

### Performance Targets
- [ ] Startup time < 2 seconds
- [ ] Video load time < 1 second
- [ ] Download start < 500ms
- [ ] UI responsiveness > 50 FPS
- [ ] Memory usage < 150MB
- [ ] No memory leaks

### Quality Gates
- [ ] Zero crashes
- [ ] Zero ANRs (Android Not Responding)
- [ ] Zero unhandled exceptions
- [ ] All features working
- [ ] All UI elements visible
- [ ] All animations smooth

---

## Testing Notes

### For Testers
1. Test on multiple devices
2. Test with different network speeds
3. Test with limited storage
4. Test with low memory
5. Report any issues with device, OS version, and steps

### For Developers
1. Check crash logs if issues found
2. Monitor device performance metrics
3. Use Flutter DevTools for profiling
4. Check Logcat for errors (Android)
5. Check Console for errors (iOS)

---

## Reporting Issues

If any test fails, document:
1. **Device:** Model, OS version
2. **Test:** Which step failed
3. **Expected:** What should happen
4. **Actual:** What actually happened
5. **Steps:** How to reproduce
6. **Logs:** Error messages or stack traces
7. **Screenshots:** If applicable

---

## Success Criteria

✅ **All tests pass** → Ready for production
⚠️ **Some minor issues** → Can be fixed in next update
❌ **Critical failures** → Must fix before release

---

**Testing Status:** Ready to Execute ✅

Good luck with testing! 🚀
