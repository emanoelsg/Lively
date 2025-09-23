# Play Store Publishing Guide for Lively

## Step 1: Prepare Your App

1. Update the app version in `pubspec.yaml`:
   ```yaml
   version: 1.0.0+1  # Format: version_name+version_code
   ```

2. Update Android Manifest (`android/app/src/main/AndroidManifest.xml`):
   - Verify permissions are correctly set
   - Ensure the app label is correct
   - Check that the package name is unique

3. Update Android signing configuration:
   ```bash
   # Generate keystore if you haven't already
   keytool -genkey -v -keystore c:\keys\lively.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias lively
   ```

4. Configure signing in `android/app/build.gradle`:
   ```gradle
   android {
       signingConfigs {
           release {
               keyAlias 'lively'
               keyPassword '***'
               storeFile file('path/to/lively.jks')
               storePassword '***'
           }
       }
   }
   ```

## Step 2: Create Required Assets

1. App Icon (required sizes):
   - 48x48 px
   - 72x72 px
   - 96x96 px
   - 144x144 px
   - 192x192 px
   - 512x512 px
   - Feature Graphic (1024x500 px)

2. Screenshots (minimum 2, maximum 8):
   - Phone Screenshots (16:9 or 9:16)
   - 7-inch Tablet (16:9 or 9:16)
   - 10-inch Tablet (16:9 or 9:16)

3. Content for Store Listing:
   ```markdown
   Short Description (80 characters):
   Lively - Your personal monthly expense manager that works 100% offline.

   Full Description (4000 characters):
   Lively is a simple and efficient monthly expense manager that helps you track your spending and stay within your budget. 

   Key Features:
   - Monthly budget tracking
   - Visual expense reports
   - Works completely offline
   - Simple and intuitive interface
   - Free and no ads

   Privacy and Security:
   - No internet connection required
   - All data stays on your device
   - No personal information collected
   ```

## Step 3: Configure Play Store Listing

1. Access the Google Play Console (play.google.com/console)

2. Create a new application

3. Fill in the store listing:
   - Title: "Lively - Budget Manager"
   - Short description
   - Full description
   - Graphics and screenshots
   - App category: Finance
   - Content rating
   - Contact details
   - Privacy policy URL

4. Complete the rating questionnaire

5. Set up pricing and distribution:
   - Select countries
   - Set price (Free)
   - Confirm content guidelines compliance

## Step 4: Build and Upload Release

1. Build release APK/App Bundle:
   ```bash
   flutter build appbundle --release
   ```

2. Upload to Play Store:
   - Go to "Release Management" > "App releases"
   - Create a new release
   - Upload the app bundle
   - Add release notes
   - Review and roll out

## Step 5: Final Checklist

- [ ] App version updated
- [ ] Keystore secure and backed up
- [ ] All required assets created
- [ ] Privacy policy in place
- [ ] Content rating completed
- [ ] App tested on multiple devices
- [ ] Release notes written
- [ ] CI/CD pipeline updated for release

## Post-Release

1. Monitor the release rollout
2. Check crash reports
3. Monitor user feedback
4. Prepare for quick fixes if needed

## Important Notes

- Keep your keystore file secure - losing it means you can't update your app
- Test thoroughly on different devices before release
- Consider staged rollout for major updates
- Keep release notes clear and concise
- Monitor Play Store reviews regularly
- Have a support system in place for user queries