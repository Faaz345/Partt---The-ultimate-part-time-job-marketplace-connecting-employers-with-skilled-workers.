# Partt App Branding Setup Guide

## 🎨 Brand Colors Implementation

The app has been updated with your brand colors:

- **Primary Color**: `#268FD3` (Main color)
- **Secondary Color**: `#C4EA35` (Secondary/accent color)
- **Dark Mode Color**: `#2C353A` (Dark mode black)

These colors are now applied throughout the app in:
- AppBar backgrounds
- Button colors
- Text colors
- UI elements
- Loading indicators

## 📱 Logo Implementation

### Required Logo Files

You need to add these logo files to the `assets/images/` folder:

1. **`partt_main_logo.png`** - Main logo used in splash screen and primary locations
2. **`partt_app_logo.png`** - App logo for secondary uses
3. **`partt_icon.png`** - Icon version for small spaces

### Logo Specifications

- **Format**: PNG with transparent background
- **Main Logo**: 512x512px minimum (square format)
- **App Logo**: 256x256px minimum
- **Icon**: 128x128px minimum

### Current Logo Usage

- Splash screen uses the main logo with fallback to "P" text
- Other screens can use `AppConstants.logoApp` or `AppConstants.logoIcon`

## 🔤 Custom Font Setup

### Font Family Configuration

The app is configured to use `ParttFont` as the custom font family.

### Required Font Files

Add your font files to the `assets/fonts/` folder with these exact names:

1. **`ParttFont-Regular.ttf`** (Weight: 400) - Regular text
2. **`ParttFont-Medium.ttf`** (Weight: 500) - Medium weight
3. **`ParttFont-SemiBold.ttf`** (Weight: 600) - Semi-bold
4. **`ParttFont-Bold.ttf`** (Weight: 700) - Bold text

### Optional Font Weights

If you have additional font weights, uncomment these lines in `pubspec.yaml`:

```yaml
# - asset: assets/fonts/ParttFont-Light.ttf
#   weight: 300
# - asset: assets/fonts/ParttFont-ExtraBold.ttf
#   weight: 800
```

### Font Integration

The custom font is automatically applied to:
- All text throughout the app
- Button text
- AppBar titles
- Form labels
- Body text
- Headings

## 🚀 Setup Instructions

### Current Status ✅

**What's Already Done:**
- ✅ Brand colors implemented throughout the app
- ✅ Logo integration ready (with fallback)
- ✅ Custom font structure prepared
- ✅ App builds successfully
- ✅ Theme system updated with your branding

### Step 1: Add Your Logo Files

1. **Replace the placeholder files** in the `assets/images/` folder:
   - Replace `partt_main_logo.png` with your main logo
   - Replace `partt_app_logo.png` with your app logo  
   - Replace `partt_icon.png` with your icon

### Step 2: Add Your Font Files (Optional)

1. **Add your font files** to the `assets/fonts/` folder:
   - `ParttFont-Regular.ttf`
   - `ParttFont-Medium.ttf` 
   - `ParttFont-SemiBold.ttf`
   - `ParttFont-Bold.ttf`

2. **Uncomment the fonts section** in `pubspec.yaml`:
   ```yaml
   # Remove the # comments from these lines:
   fonts:
     - family: ParttFont
       fonts:
         - asset: assets/fonts/ParttFont-Regular.ttf
           weight: 400
         # ... etc
   ```

### Step 3: Test Your Changes

```bash
# Clean build cache (only needed if adding fonts)
flutter clean

# Get dependencies 
flutter pub get

# Run the app
flutter run
```

### Step 4: Verify Branding

- 🎨 **Colors**: Check if your brand colors appear correctly
- 📱 **Logo**: Verify your logo shows in the splash screen
- 🔤 **Fonts**: Confirm custom fonts are applied (if added)

## 🎯 Using Brand Assets in Code

### Using Logos

```dart
// Main logo
Image.asset(AppConstants.logoMain)

// App logo
Image.asset(AppConstants.logoApp)

// Icon
Image.asset(AppConstants.logoIcon)
```

### Using Brand Colors

```dart
// Primary color
Container(color: AppConstants.primaryColor)

// Secondary color
Container(color: AppConstants.secondaryColor)

// Dark mode color
Container(color: AppConstants.darkModeBlack)
```

### Using Custom Font

The font is automatically applied, but you can explicitly use it:

```dart
Text(
  'Custom Text',
  style: TextStyle(
    fontFamily: AppConstants.fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  ),
)
```

## 🔧 Troubleshooting

### Font Not Showing

1. Ensure font files are in `assets/fonts/` folder
2. Check file names match exactly (case-sensitive)
3. Run `flutter clean` and `flutter pub get`
4. Restart the app

### Logo Not Showing

1. Ensure image files are in `assets/images/` folder
2. Check file extensions are `.png`
3. Verify file names match exactly
4. Try hot reload or hot restart

### Color Issues

The colors are defined in `lib/core/constants/app_constants.dart` and applied in `lib/main.dart`. If colors aren't showing:

1. Check if the hex values are correct
2. Restart the app completely
3. Check if custom themes are overriding the colors

## 📝 Notes

- The app uses responsive design with `flutter_screenutil`
- All fonts and colors are centralized in constants for easy management
- Fallback mechanisms are in place if assets fail to load
- The theme supports both light mode (dark mode can be added later)

## 🎨 Dark Mode Support

The constants include dark mode colors. To implement dark mode:

1. Create a dark theme in `main.dart`
2. Use `AppConstants.darkBackground` and `AppConstants.darkSurface`
3. Switch text colors appropriately for dark backgrounds

---

**Ready to go!** Once you add your logo and font files, the app will automatically use your complete branding throughout the interface.