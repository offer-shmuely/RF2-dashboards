# Installation Guide for RF2-dashboards on RadioMaster TX16S

This guide provides step-by-step instructions for installing RF2-dashboards widget on RadioMaster TX16S running EdgeTX 2.11.0 or above.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Download the Widget](#download-the-widget)
3. [Understanding the SD Card Structure](#understanding-the-sd-card-structure)
4. [Installing the Files](#installing-the-files)
5. [Setting Up the Widget](#setting-up-the-widget)
6. [Verification](#verification)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before you begin, ensure you have:

- **RadioMaster TX16S** radio transmitter
- **EdgeTX 2.11.0 or higher** installed on your radio
  - To check your EdgeTX version, go to: `MENU > RADIO SETUP > VERSION`
  - If you need to update EdgeTX, visit: [EdgeTX Downloads](https://github.com/EdgeTX/edgetx/releases)
- **MicroSD card** (the SD card that came with your TX16S or a compatible replacement)
- **SD card reader** or USB cable to connect TX16S to your computer
- **Computer** (Windows, Mac, or Linux)
- **RF2-dashboards files** (downloaded from GitHub)

### Compatible Radios

While this guide focuses on the RadioMaster TX16S, RF2-dashboards is compatible with other EdgeTX radios including:
- RadioMaster TX16S MkII
- Radiomaster TX12
- FrSky X10/X10S
- FrSky X12S
- And other color screen EdgeTX radios

---

## Download the Widget

1. Visit the [RF2-dashboards GitHub repository](https://github.com/offer-shmuely/RF2-dashboards)

2. Click on the green **"Code"** button, then select **"Download ZIP"**

   ![Download from GitHub](images/01-github-download.png)

3. Extract the ZIP file to a location on your computer (e.g., your Desktop or Downloads folder)

4. You should now have a folder named `RF2-dashboards-main` (or similar) containing:
   - `SCRIPTS` folder
   - `WIDGETS` folder
   - `README.md`
   - `LICENSE`

---

## Understanding the SD Card Structure

EdgeTX uses a specific folder structure on the SD card. The relevant folders for this widget are:

```
SD CARD ROOT/
├── SCRIPTS/
│   └── RF2-dashboards/         ← Server scripts go here
│       ├── rf2_dashboard.lua
│       ├── dashboards/
│       ├── tasks/
│       └── ... (other files)
└── WIDGETS/
    ├── rf2_dashboard/          ← Dashboard widget goes here
    │   └── main.lua
    └── rf2_server/             ← Server widget goes here
        └── main.lua
```

**Important Notes:**
- The `SCRIPTS` folder contains the main logic and functionality
- The `WIDGETS` folder contains the widget interfaces
- Both folders are required for the widget to work properly

---

## Installing the Files

### Step 1: Access Your SD Card

**Option A: Using USB Cable**
1. Turn on your RadioMaster TX16S
2. Connect it to your computer using a USB cable
3. On the radio, press the `MENU` button
4. Navigate to `RADIO SETUP`
5. Select `USB Mode: Storage (SD)`
6. The SD card should now appear as a drive on your computer

   ![USB Mode Selection](images/02-usb-mode.png)

**Option B: Using SD Card Reader**
1. Power off your RadioMaster TX16S
2. Remove the MicroSD card from the radio (located on the right side)
3. Insert the SD card into your card reader
4. Connect the card reader to your computer

### Step 2: Copy the SCRIPTS Folder

1. Open the extracted `RF2-dashboards-main` folder on your computer

2. Locate the `SCRIPTS` folder

3. Open the SD card drive

4. **If a `SCRIPTS` folder already exists on the SD card:**
   - Open it
   - Copy the entire `RF2-dashboards` folder from the downloaded files
   - Paste it into the existing `SCRIPTS` folder on the SD card
   
   Result: `SD:/SCRIPTS/RF2-dashboards/`

5. **If no `SCRIPTS` folder exists:**
   - Create a new folder named `SCRIPTS` on the SD card root
   - Copy the `RF2-dashboards` folder into it

### Step 3: Copy the WIDGETS Folder

1. Go back to the extracted `RF2-dashboards-main` folder

2. Locate the `WIDGETS` folder

3. **If a `WIDGETS` folder already exists on the SD card:**
   - Open it
   - Copy both `rf2_dashboard` and `rf2_server` folders from the downloaded files
   - Paste them into the existing `WIDGETS` folder on the SD card
   
   Result: 
   - `SD:/WIDGETS/rf2_dashboard/`
   - `SD:/WIDGETS/rf2_server/`

4. **If no `WIDGETS` folder exists:**
   - Create a new folder named `WIDGETS` on the SD card root
   - Copy both widget folders into it

### Step 4: Safely Eject the SD Card

1. **If using USB cable:**
   - On your computer, safely eject the SD card drive
   - On the radio, press `EXIT` to return to normal mode

2. **If using SD card reader:**
   - Safely eject the SD card from your computer
   - Insert the SD card back into your RadioMaster TX16S
   - Power on the radio

---

## Setting Up the Widget

Now that the files are installed, you need to add the widget to your model's screen layout.

### Step 1: Access Your Model Settings

1. Turn on your RadioMaster TX16S
2. Select the model you want to add the dashboard to (long press `MENU` to access model selection)
3. Press `MENU` to enter the main menu
4. Navigate to `MODEL SETUP` (if not already there)

   ![Model Setup Menu](images/03-model-setup.png)

### Step 2: Configure Screen Layout

1. From the model menu, navigate to `SCREEN SETUP` or `WIDGETS`
   
   ![Screen Setup](images/04-screen-setup.png)

2. Select a screen layout that has widget zones available:
   - For full screen widget: Select a layout with one large zone (e.g., "Full screen")
   - For multiple widgets: Select a layout with multiple zones
   
   ![Screen Layout Selection](images/05-layout-selection.png)

### Step 3: Add the RF2 Dashboard Widget

1. Tap on an empty widget zone or a zone you want to replace

2. Select **"Select widget"** (or tap the widget name if replacing)

   ![Widget Selection Menu](images/06-widget-select.png)

3. Scroll through the available widgets until you find **"rf2_dashboard"**

4. Select **"rf2_dashboard"**

   ![RF2 Dashboard Widget](images/07-rf2-dashboard-select.png)

5. The widget should now appear in the selected zone

### Step 4: Add the RF2 Server Widget (Required)

The RF2 Server widget runs in the background and handles telemetry data. It's essential for the dashboard to work.

1. Find a small widget zone (can be minimized or hidden)

2. Select **"Select widget"**

3. Choose **"rf2_server"** from the list

   ![RF2 Server Widget](images/08-rf2-server-select.png)

4. The server widget can be placed in any zone (it doesn't need to be visible)

### Step 5: Configure Widget Options (Optional)

1. Long-press on the **rf2_dashboard** widget

2. Select **"Widget settings"** or tap the settings icon

   ![Widget Settings](images/09-widget-settings.png)

3. Available options may include:
   - Dashboard style selection
   - Color themes
   - Display preferences
   - Unit settings (metric/imperial)

4. Adjust settings according to your preferences

5. Press `EXIT` or `BACK` to save and return

---

## Verification

### Test the Widget Display

1. From the main screen, navigate to the model with the RF2 dashboard widget

2. The widget should display:
   - RF2 logo or connection status
   - "No telemetry" or "Waiting for connection" message if not connected to a model
   
   ![Widget No Connection](../SCRIPTS/RF2-dashboards/img/no_connection_wr.png)
   
   *Example: The widget displays the RF2 logo with a "No Connection" indicator when no telemetry is received.*

3. If you have a Rotorflight 2 flight controller connected:
   - Power on your helicopter/aircraft
   - The widget should display live telemetry data
   - You should see flight parameters like:
     - Battery voltage
     - Current
     - RPM (head speed)
     - Temperature
     - GPS data (if available)
   
   
   **Dashboard Style 1:**
   <img width="488" height="283" alt="RF2 Dashboard Style 1" src="https://github.com/user-attachments/assets/e64ba49f-81d0-454a-ad93-c7a7bf33ffdf" />
   
   **Dashboard Style 2:**
   <img width="490" height="285" alt="RF2 Dashboard Style 2" src="https://github.com/user-attachments/assets/db48e464-5c2c-479f-8128-add91d624189" />
   
   *Examples: Live telemetry data displayed in different dashboard styles.*

### Common Display States

- **No Connection**: Widget shows RF2 logo with "No Connection" or "Waiting"
- **Connected**: Widget displays live telemetry data with active flight parameters
- **Post-Flight**: After landing, widget may switch to post-flight summary view

---

## Troubleshooting

### Widget Not Appearing in the Widget List

**Possible causes:**
- Files not copied to the correct location
- EdgeTX version is too old (requires 2.11.0+)

**Solutions:**
1. Verify files are in the correct folders:
   - `SD:/WIDGETS/rf2_dashboard/main.lua`
   - `SD:/WIDGETS/rf2_server/main.lua`
   - `SD:/SCRIPTS/RF2-dashboards/` folder exists with all files

2. Restart your radio (power off, then power on)

3. Check EdgeTX version: `MENU > RADIO SETUP > VERSION`
   - Must be 2.11.0 or higher
   - Update EdgeTX if needed

### Widget Shows Only Black Screen or Error

**Possible causes:**
- Missing server widget
- Corrupted files
- Incompatible EdgeTX version

**Solutions:**
1. Ensure both widgets are added:
   - `rf2_dashboard` (main display)
   - `rf2_server` (background service)

2. Re-download and copy the files

3. Check the EdgeTX version matches requirements (2.11.0+)

4. Check the Lua error console:
   - Press `MENU > RADIO SETUP > Lua CONSOLE`
   - Look for error messages

   ![Lua Console](images/12-lua-console.png)

### Widget Shows "Warning" Message About EdgeTX Version

**Cause:**
- EdgeTX version below 2.11.3

**Solution:**
- The widget will still work, but updating to EdgeTX 2.11.3 or higher is recommended
- Download latest EdgeTX from: [EdgeTX Releases](https://github.com/EdgeTX/edgetx/releases)

### No Telemetry Data Displayed

**Possible causes:**
- Rotorflight flight controller not connected
- Telemetry not configured properly
- Wrong model selected

**Solutions:**
1. Verify your Rotorflight 2 flight controller is powered on and connected

2. Check your radio link (ELRS, CRSF, etc.) is active

3. Verify telemetry is enabled in your model settings:
   - `MENU > MODEL SETUP > TELEMETRY`

4. Check your flight controller's telemetry output is configured correctly

### Widget Disappeared After EdgeTX Update

**Cause:**
- Known issue with EdgeTX versions below 2.11.3

**Solution:**
1. Update EdgeTX to 2.11.3 or higher
2. The widget includes a warning message for older versions
3. Re-add the widget if necessary after EdgeTX update

### Audio Alerts Not Working

**Possible causes:**
- Sound files missing
- Volume too low
- Audio settings disabled

**Solutions:**
1. Check that sound files are installed:
   - `SD:/SCRIPTS/RF2-dashboards/sounds/` folder should contain audio files

2. Adjust global volume: `MENU > RADIO SETUP > AUDIO`

3. Check widget audio settings in widget options

---

## Additional Resources

- **GitHub Repository**: [https://github.com/offer-shmuely/RF2-dashboards](https://github.com/offer-shmuely/RF2-dashboards)
- **Project Wiki**: [https://github.com/offer-shmuely/RF2-dashboards/wiki](https://github.com/offer-shmuely/RF2-dashboards/wiki)
- **EdgeTX Documentation**: [https://edgetx.org/](https://edgetx.org/)
- **Rotorflight**: [https://www.rotorflight.org/](https://www.rotorflight.org/)

---

## Getting Help

If you encounter issues not covered in this guide:

1. Check the [GitHub Issues](https://github.com/offer-shmuely/RF2-dashboards/issues) page
2. Review the [Wiki](https://github.com/offer-shmuely/RF2-dashboards/wiki) for additional information
3. Create a new issue with:
   - Your radio model (e.g., RadioMaster TX16S)
   - EdgeTX version
   - Description of the problem
   - Screenshots if applicable

---

## Version History

- **v1.0** (2026-02) - Initial installation guide for EdgeTX 2.11+

---

**Note**: This software is provided "as is" without warranty of any kind. Always ensure your aircraft is safe to fly and follow all local regulations.
