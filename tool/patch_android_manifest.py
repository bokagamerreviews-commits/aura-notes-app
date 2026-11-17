import os

manifest_path = "android/app/src/main/AndroidManifest.xml"
if os.path.exists(manifest_path):
    with open(manifest_path, "r", encoding="utf-8") as f:
        content = f.read()

    permissions = '''    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
'''
    if "READ_MEDIA_IMAGES" not in content:
        content = content.replace("<application", permissions + "    <application", 1)

    # Set clean app label
    content = content.replace('android:label="aura_notes"', 'android:label="Aura Notes"')

    with open(manifest_path, "w", encoding="utf-8") as f:
        f.write(content)
    print("Patched AndroidManifest.xml successfully.")
else:
    print("AndroidManifest.xml not found, skipping patch.")
