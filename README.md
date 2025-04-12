# ApkAutomate

# Android APK Puller, Merger & Signer Tool (Batch Script)

📱 A lightweight batch script that automates the following tasks:

1. Lists all installed user apps on a connected Android device.
2. Allows selection and pulling of APK(s) from a specific app.
3. Automatically merges APK splits (if multiple APKs).
4. Signs the final APK using `uber-apk-signer`.
5. Auto-checks and updates the required tools from GitHub (APKEditor & uber-apk-signer).

---

## 🔧 Requirements

- [ADB](https://developer.android.com/tools/adb) installed and added to system PATH.
- Windows machine (batch script).
- Internet connection (to fetch latest releases of tools).
- Android device with USB debugging enabled.

---

## 📁 Tools Used

| Tool              | Source Repository                                                                 |
|-------------------|-----------------------------------------------------------------------------------|
| APKEditor         | [REAndroid/APKEditor](https://github.com/REAndroid/APKEditor)                    |
| uber-apk-signer   | [patrickfav/uber-apk-signer](https://github.com/patrickfav/uber-apk-signer)      |

These are automatically downloaded into the configured `tools` folder if not present or outdated.

---

## 🚀 How to Use

1. Clone this repository or download the batch script.
2. Make sure `ADB` is set up and a device is connected.
3. Place the batch script anywhere and run it.
4. Enter a keyword to filter the package list (or press Enter to list all).
5. Select the app by number.
6. Enter a folder name to store the pulled APKs.
7. The script will:
   - Pull APK(s)
   - Merge if necessary
   - Sign the APK automatically

---

## 📦 Output

The signed APK will be stored in the folder you specify (e.g., `YourFolderName/signed/`).

---

## 🛠 Customization

You can change the tools directory by editing this line in the script:

```bat
set "TOOLSDIR=SET Your Tool Path"

```

## Notes

1. If the selected app has multiple APK splits, they will be merged automatically.

2. Signed APKs can be found in the signed subdirectory created by uber-apk-signer.




## Donate

If you found this tool useful and would like to support its development.

---

Let me know if you'd like to modify or add anything else!

## 🙏 Special Thanks

A big thank you to the developers of the following tools:

- **[uber-apk-signer](https://github.com/patrickfav/uber-apk-signer)**: For providing a simple and efficient way to sign APKs with robust features.
- **[APKEditor](https://github.com/REAndroid/APKEditor)**: For creating a powerful tool to modify APK files and merge APK splits.

Their hard work and dedication make this tool possible!





