# Complete Guide to Setup Car Parking Android App (Linux & Windows).

## Getting Started

This guide will walk you through the steps to set up Android Studio and run this project on your machine, covering both **Linux (Ubuntu)** and **Windows**.  
**Additional guides for backend setups (local & AWS EC2) are linked where relevant.**

---

## 1. Steps to Setup Android Studio

### a. Navigate to the official website for downloading the Android Studio

[https://developer.android.com/studio](https://developer.android.com/studio)

### b. Download Android Studio:

- **Linux:** Click *Download*. You’ll get a `.tar.gz` archive.
- **Windows:** Click *Download*. You’ll get an `.exe` installer.

### c. Install Android Studio

#### **Linux**

Open your terminal and navigate to Downloads folder.

```bash
cd Downloads
tar -zxvf android-studio-*.tar.gz
```
*(replace `android-studio-*.tar.gz` with the actual filename)*

#### **Windows**

- Double-click the downloaded `.exe` file.
- Follow the wizard steps, accept the terms, and choose the install location (default is fine).
- Complete installation.

### d. Move the extracted folder to more permanent place (Linux only, optional)

```bash
sudo mv android-studio /opt/
```

### e. Run the Android Studio Startup Script

- **Linux:**
```bash
cd /opt/android-studio/bin
./studio.sh
```
- **Windows:** Launch *Android Studio* from Start Menu or Desktop.

### f. Check if it installed

- **Linux:**
```bash
android-studio
```
- **Windows:** Verify Android Studio launches successfully.

### g. Create a Desktop Entry (Linux only, optional/recommended for Easy Launching)

```bash
mkdir -p ~/.local/share/applications/
nano ~/.local/share/applications/android-studio.desktop
```

Paste the following content (adjust Path and Exec lines if not using /opt):

```ini
[Desktop Entry]
Name=Android Studio
Comment=The official IDE for Android development
Exec=/opt/android-studio/bin/studio.sh
Icon=/opt/android-studio/bin/studio.png
Type=Application
Terminal=false
Categories=Development;IDE;
StartupWMClass=jetbrains-studio
```

Save and exit (`Ctrl+O`, Enter, then `Ctrl+X`).  
Update desktop database:

```bash
sudo update-desktop-database ~/.local/share/applications/
```

### **Important Considerations**

#### a. **Java Development Kit (JDK)**

- **Linux:** Android Studio may prompt for JDK download. You can install manually:
```bash
sudo apt update
sudo apt install openjdk-17-jdk # Or a later version
```
- **Windows:** Android Studio includes OpenJDK. *(If needed, download from [https://adoptopenjdk.net](https://adoptopenjdk.net) and install manually.)*

#### b. **System Requirements**

- Ensure your Ubuntu/Windows system meets minimum requirements: RAM (8GB+ recommended), disk space (4GB+), compatible CPU.

---

## 2. Steps to Install Emulator Inside Android Studio

### a. Click the Device Manager icon (top-right).

### b. Click the **+** icon and select **Create Virtual Device**.

### c. Select a device definition, click Next, choose a system image, then Next.

### d. Name your emulator and click Finish (or Install if system image needs downloading).

### e. Find/emulate in Device Manager.

### **Recommended AVD configuration for this project**
- **Device profile:** Pixel 2 (or any 5.0" phone profile)
- **System image / API level:** API 28 (Android 9.0 Pie) with **Google APIs**
- **ABI:** x86_64
- **Screen resolution:** 1080 × 1920 (420 dpi)
- **Services:** Google APIs (required for Maps/location)
- **RAM & CPU cores:** 4 & max
- **Options:** Enable hardware accelerated virtualization (Intel HAXM or KVM on Linux)

#### Why this configuration?
- Uses Google Maps/services (Google APIs required).
- API 28 is stable and compatible.
- x86_64 images run faster under virtualization.
- Matches Pixel 2 layout for reliable UI testing.

#### **If system image isn’t downloaded:** Click **Install** and wait for download.

#### **If you wish to test multiple densities/versions:** Create extra AVDs and keep "Allow multiple instances" enabled in Run configuration.

---

#### **Emulator Performance Tips (Linux & Windows)**

##### **Linux: KVM Virtualization**
Check CPU support:
```bash
egrep -c '(vmx|svm)' /proc/cpuinfo
```
Install and enable KVM:
```bash
sudo apt update
sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils
sudo adduser $USER kvm
sudo adduser $USER libvirt
```
Log out and back in to apply groups  
Verify:
```bash
virsh -c qemu:///system list --all
```

##### **Windows: Hyper-V/Virtual Machine Platform**
- Enable Hyper-V in Windows Features or use Intel HAXM.

##### **Launch emulator from terminal**
**Linux:**
```bash
$ANDROID_SDK_ROOT/emulator/emulator -avd Your_AVD_Name -gpu host -memory 2048 -no-boot-anim
```
**Windows:**
```bash
emulator -avd Your_AVD_Name -gpu host -memory 2048 -no-boot-anim
```

---

## 3. Steps to Create a Basic Project

a. Click three horizontal bars (top left).

b. Go to **New > New Project** then select the **Empty View Activity**.

c. Click Next, name your project, and optionally provide base package name.

d. Select location, language (Kotlin/Java), click Finish.

e. Project build starts; click **Run** (top middle) after build finishes.

f. A Hello World activity will appear.

---

## 4. Steps to Clone the Car Parking Project

a. **Clone the Repository:**

- **Linux (Terminal):**
```bash
git clone https://github.com/neeraj975arora/parking_app_integration.git
```
- **Windows (Git Bash/Prompt):**
```bash
git clone https://github.com/neeraj975arora/parking_app_integration.git
```
*(GitHub Desktop also works for GUI cloning.)*

b. **Open Project in Android Studio:**
- Launch Android Studio.
- Select **"Open an existing project"** on the welcome screen.
- Navigate to the cloned repository folder.
- Click **"Open"**.

c. **Wait for Gradle Sync:**  
Android Studio will sync dependencies (check status bar).

d. **Build the Project:**  
Menu → **Build > Make Project**. Watch "Build" output for errors.

e. **Run the Application:**  
Use the Run (▶) button or **Run > Run 'app'**.

### Edit Run/Debug Configurations:

1. **Select Android App Configuration:**  
   Left pane → *Android App → app*. If missing, click + to add.

2. **Module:**  
   Set to correct module (e.g., `VisionPark.app` or just `app`).

3. **Installation Options:**
- Deploy: Default APK
- Install for all users: Optional
- Always install with package manager: Optional
- Clear app storage before deployment: Optional
- Install Flags: Advanced (e.g., `-r`, `-d`, `-t`)

4. **Launch Options:**
- Launch: Default Activity or specify exact activity
- Launch Flags: Optional

5. **Miscellaneous:**
- Allow multiple instances: Enables multi-device testing
- Store as project file: Shares config across team

6. **Before Launch:**
- Ensure Gradle-aware Make or Make/Assemble task present

7. **Debugger:**
- Default debugger settings suffice

### Examples / Tips

- Launch a specific activity: set *Specified Activity* field to full activity name.
- Enable *Clear app storage before deployment* for fresh testing.
- For ADB install errors: try *APK from app bundle* or add `-r` install flag.
- For multi-device runs, enable *Allow multiple instances*.

Pick your device/emulator and click **Run**.

---

## 5. Steps to Get the Google Map API Key

- Create Google Cloud account: [https://console.cloud.google.com/](https://console.cloud.google.com/)
- Create new project
- Enable **Android Maps SDK**
- Go to *Credentials* tab, copy API key
- Paste API key in `local.properties` file

---

## 6. Android Emulator & Build Performance Tips

Tips for Ubuntu, Windows, Android Studio, VS Code, and Android Emulator.

### 6.1 Quick Checklist

1. **Use a real device (fastest):** USB debug with `adb` or *scrcpy*.
2. **Enable virtualization (KVM/Hyper-V):**
- Linux: see above
- Windows: Enable Hyper-V in “Windows Features”
3. **Switch AVD to x86_64 with host GPU** (not ARM), enable snapshots/quick-boot.
4. **Reduce emulator RAM/resolution/features**.
5. **Tweak Android Studio & Gradle settings**.
6. **Close heavy apps/reduce IDE indexing**.

### 6.2 Concrete Steps & Commands

#### Linux: Virtualization (KVM)

```bash
egrep -c '(vmx|svm)' /proc/cpuinfo
```
Install KVM as shown in previous section

#### Windows: Hyper-V

- Enable Hyper-V/Virtual Machine Platform via Control Panel → “Turn Windows features on or off”.

#### Use x86_64 emulator image + host GPU (both OS)

- Use AVD Manager: Pick x86_64 image, host GPU, set memory 1536–2048 MB, enable quick boot snapshots.

#### If machine has low RAM (<= 8 GB)
- Prefer real device (USB debug).
  - Windows: Use *scrcpy* ([https://github.com/Genymobile/scrcpy](https://github.com/Genymobile/scrcpy)), installable via Windows installer.
  - Linux: `sudo apt install scrcpy`

#### Gradle performance tweaks

In `~/.gradle/gradle.properties` or project `gradle.properties`:
```bash
org.gradle.daemon=true
org.gradle.parallel=true
org.gradle.configureondemand=true
org.gradle.jvmargs=-Xmx1536m -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8
org.gradle.caching=true
```
Increase/decrease `-Xmx` as needed by RAM.

#### Build from terminal (if Android Studio is slow):

```bash
./gradlew assembleDebug
adb install -r app/build/outputs/apk/debug/app-debug.apk
```

#### Improve Android Studio performance

- Increase IDE heap (Settings → Memory).
- Disable unused plugins.
- Exclude large folders from indexing (right-click → Mark Directory As → Excluded).
- Disable Instant Run/Apply Changes if slow.

#### AVD configuration tips

- Use small device profiles, disable Google Play if unnecessary.
- Disable animations for speed.
- Try fallback GPU on Linux (`-gpu swiftshader_indirect`) if host GPU causes issues.

#### Avoid double-indexing apps

- Use VS Code for editing, Android Studio for builds as needed.
- Turn off automatic Gradle sync on file changes.
- Close Chrome/other heavy apps while emulating/building.

#### System-level improvements

- Use SSD for huge speedup.
- Add RAM (16GB+ ideal).
- Use zram/increase swap only if desperate.

#### Diagnose freezes

- Use `htop`/System Monitor for real-time info.
- Check `dmesg` for errors.
- Use Android Studio Profiler for app issues.

---

## 7. API Endpoints & Structure Reference

For all endpoints and request/response formats for User app REST APIs, see  
**[User API Specs (REST_API_Specs)](../REST_API_Specs/USER_APP_REST_API_SPECS.md)**


---

## 8. Backend Integration and Setup

Current backend application is dockerized.  
See **[Backend/Readme.md](../Backend/Readme.md)** for setup.


## 8.1 For Switching to EC2 Server or Local Server

For switching between local backend and AWS EC2 server, refer to  
**[SwitchToEC2Guide.md](../Vision-Parking/SwitchToEC2Guide.md)**



---

## 9. Steps to Setup PostgreSQL

### 1. Install PostgreSQL

#### **Linux**
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install postgresql postgresql-contrib -y
sudo systemctl start postgresql
sudo systemctl enable postgresql
sudo systemctl status postgresql
```

#### **Windows**
- Download and run the official installer: [https://www.postgresql.org/download/windows/](https://www.postgresql.org/download/windows/)
- Choose install directories, set postgres password, complete wizard.
- Service starts automatically. Check via **Services.msc** (“postgresql-x64-XX” running).
- Access PostgreSQL shell:
  - Run *SQL Shell (psql)* from Start Menu.
  - Set password during setup if prompted.

### 2. Configure PostgreSQL

#### **Linux**
```bash
sudo -i -u postgres
psql
ALTER USER postgres PASSWORD 'your_password';
\q
exit
```

#### **Windows**
- Run *SQL Shell (psql)*, login as user `postgres`.
- Enter password (set during install or `ALTER USER` command).
- Use SQL commands as above.

### 3. Installing the GUI Tool pgAdmin for PostgreSQL

#### **Linux**
```bash
curl https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo tee /etc/apt/trusted.gpg.d/pgadmin.asc
sudo sh -c 'echo "deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list'
sudo apt update
sudo apt install pgadmin4 -y
```

#### **Windows**
- Download & install from [https://www.pgadmin.org/download/](https://www.pgadmin.org/download/)
- Follow wizard, set email/password.

### 4. Configure And Access pgAdmin

#### **Linux**
```bash
sudo /usr/pgadmin4/bin/setup-web.sh
```
Browse to [**http://localhost/pgadmin4**](http://localhost/pgadmin4), login with setup credentials.

#### **Windows**
- Start *pgAdmin 4* from Start menu.

### 5. Connect to a New Server Connection

In pgAdmin (Linux & Windows):

a. Right-click *Servers* → Create → Server...

b. General tab: Name your server (e.g., MyDatabaseServer)
c. Connection tab:
- Host: `localhost` (or server IP)
- Port: `5432`
- Maintenance DB: your db name
- Username: `postgres` (or chosen user)
- Password: as set above
  d. Save password if desired.
  e. Click **Save**.

### 6. Access a Specific Database

a. Expand the server you just added.
b. Expand *Databases*, select your db.
c. Click SQL icon (⚡) to open Query Tool.
d. Run queries.

---

**Now we have done with all the necessary steps. You can successfully run the Car Parking app in Android Studio across Linux or Windows, with backend and database setup (local or AWS EC2).**

---
## 10.Test Plan – VisionPark App
To test the VisionPark Android app with E2E Integration test cases using Appium+Pytest, refer to  
**[plan.md](../plan.md)**

## 11. References

- **Android Studio:** [https://developer.android.com/studio](https://developer.android.com/studio)
- **Git:** [https://git-scm.com/](https://git-scm.com/)
- **PostgreSQL:** [https://www.postgresql.org/](https://www.postgresql.org/)
- **pgAdmin:** [https://www.pgadmin.org/](https://www.pgadmin.org/)
- **Google Cloud Console:** [https://console.cloud.google.com/](https://console.cloud.google.com/)
- **Switch to EC2 Guide:** [SwitchToEC2Guide.md](../SwitchToEC2Guide.md)
