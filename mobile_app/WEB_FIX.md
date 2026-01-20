# Web Platform Compatibility Notes

## Current Status

The app is configured to run on web, but note:

1. **SQLite Database**: Not supported on web
   - App will show initialization messages
   - Data won't persist (in-memory only)
   - This is expected behavior

2. **TensorFlow Lite**: Not supported on web
   - AI features will show "model not initialized"
   - UI will still work

3. **Platform-specific features**:
   - Some features work best on mobile (Android/iOS)
   - Web is good for testing UI

## To See Full Features

Run on **Windows Desktop** or **Android/iOS** for:
- Full database support
- TensorFlow Lite AI model
- Complete functionality

## For Web Testing

The app will:
- ✅ Load and display UI
- ✅ Show dashboard
- ⚠️ Database operations may fail (expected)
- ⚠️ AI model won't load (expected)

