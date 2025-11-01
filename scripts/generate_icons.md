# Icon Generation Guide for Arch Awaken

## Required Tools
- Image editing software (Figma, Adobe Illustrator, GIMP, etc.)
- SVG to PNG converter
- Or use online tools like: https://svgtopng.com/

## Source Files
- `/assets/logo/arch_awaken_logo.svg` - Full logo with details
- `/assets/logo/arch_awaken_icon.svg` - Simplified icon version

## Platform Requirements

### Android Icons
Location: `android/app/src/main/res/`

| Density | Size | File Name |
|---------|------|-----------|
| mdpi    | 48x48 | `mipmap-mdpi/ic_launcher.png` |
| hdpi    | 72x72 | `mipmap-hdpi/ic_launcher.png` |
| xhdpi   | 96x96 | `mipmap-xhdpi/ic_launcher.png` |
| xxhdpi  | 144x144 | `mipmap-xxhdpi/ic_launcher.png` |
| xxxhdpi | 192x192 | `mipmap-xxxhdpi/ic_launcher.png` |

### iOS Icons
Location: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

| Size | Scale | File Name |
|------|-------|-----------|
| 20x20 | @1x | `Icon-App-20x20@1x.png` |
| 20x20 | @2x | `Icon-App-20x20@2x.png` |
| 20x20 | @3x | `Icon-App-20x20@3x.png` |
| 29x29 | @1x | `Icon-App-29x29@1x.png` |
| 29x29 | @2x | `Icon-App-29x29@2x.png` |
| 29x29 | @3x | `Icon-App-29x29@3x.png` |
| 40x40 | @1x | `Icon-App-40x40@1x.png` |
| 40x40 | @2x | `Icon-App-40x40@2x.png` |
| 40x40 | @3x | `Icon-App-40x40@3x.png` |
| 60x60 | @2x | `Icon-App-60x60@2x.png` |
| 60x60 | @3x | `Icon-App-60x60@3x.png` |
| 76x76 | @1x | `Icon-App-76x76@1x.png` |
| 76x76 | @2x | `Icon-App-76x76@2x.png` |
| 83.5x83.5 | @2x | `Icon-App-83.5x83.5@2x.png` |
| 1024x1024 | @1x | `Icon-App-1024x1024@1x.png` |

### Web Icons
Location: `web/icons/`

| Size | File Name | Purpose |
|------|-----------|---------|
| 192x192 | `Icon-192.png` | Web App Manifest |
| 512x512 | `Icon-512.png` | Web App Manifest |
| 192x192 | `Icon-maskable-192.png` | PWA Maskable Icon |
| 512x512 | `Icon-maskable-512.png` | PWA Maskable Icon |
| 32x32 | `favicon.png` | Browser Tab Icon |

### macOS Icons
Location: `macos/Runner/Assets.xcassets/AppIcon.appiconset/`

| Size | File Name |
|------|-----------|
| 16x16 | `app_icon_16.png` |
| 32x32 | `app_icon_32.png` |
| 64x64 | `app_icon_64.png` |
| 128x128 | `app_icon_128.png` |
| 256x256 | `app_icon_256.png` |
| 512x512 | `app_icon_512.png` |
| 1024x1024 | `app_icon_1024.png` |

## Generation Steps

1. **Export Source SVG** to high-resolution PNG (1024x1024)
2. **Resize** to each required size
3. **Save** with correct file names in appropriate directories
4. **Test** on each platform

## Color Variations

The logo uses the Peacock theme (#00695C primary, #4DB6AC secondary). For additional branding, create variants using the other app themes:

- **Sunset**: #E65100 primary, #FF9800 secondary
- **Forest**: #2E7D32 primary, #66BB6A secondary
- **Ocean**: #1565C0 primary, #42A5F5 secondary
- **Lavender**: #7B1FA2 primary, #BA68C8 secondary

## Automated Generation (Recommended)

Use the `flutter_launcher_icons` package for automated icon generation:

```yaml
dev_dependencies:
  flutter_launcher_icons: "^0.13.1"

flutter_icons:
  android: true
  ios: true
  image_path: "assets/logo/arch_awaken_icon.png"
  adaptive_icon_background: "#00695C"
  adaptive_icon_foreground: "assets/logo/arch_awaken_icon.png"
```

Then run: `flutter pub run flutter_launcher_icons:main`