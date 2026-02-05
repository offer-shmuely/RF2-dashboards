# Visual Installation Guide - EdgeTX Widget Installation

## SD Card File Structure Diagram

This visual guide shows exactly where files should be placed on your RadioMaster TX16S SD card.

### Before Installation
```
SD CARD (Existing Structure)
├── EEPROM/
├── FIRMWARE/
├── LOGS/
├── MODELS/
├── RADIO/
├── SCREENSHOTS/
├── SCRIPTS/              ← May or may not exist
│   └── ... (other scripts)
├── THEMES/
└── WIDGETS/              ← May or may not exist
    └── ... (other widgets)
```

### After Installation (Required Files)
```
SD CARD (After RF2-dashboards Installation)
├── EEPROM/
├── FIRMWARE/
├── LOGS/
├── MODELS/
├── RADIO/
├── SCREENSHOTS/
├── SCRIPTS/
│   ├── ... (other scripts)
│   └── RF2-dashboards/                    ⭐ NEW FOLDER
│       ├── rf2_dashboard.lua              ← Main dashboard script
│       ├── rf2_dashboard_opt.lua          ← Dashboard options
│       ├── telemetry_engine.lua           ← Telemetry handler
│       ├── lib_log.lua                    ← Logging library
│       ├── lib_widget_tools.lua           ← Widget utilities
│       ├── CHANGELOG.md
│       ├── .editorconfig
│       ├── RF2/                           ← Configuration files
│       │   └── ... (config files)
│       ├── dashboards/                    ← Dashboard layouts
│       │   ├── dashboard_1.lua
│       │   ├── dashboard_2.lua
│       │   ├── dashboard_post_1.lua
│       │   └── ... (other dashboards)
│       ├── img/                           ← Images and icons
│       │   ├── rf2_logo.png
│       │   ├── rf2_logo2.png
│       │   ├── rf2_logo3.png
│       │   ├── no_connection_wr.png
│       │   ├── temperature.png
│       │   └── rf2_image_def.png
│       ├── parts/                         ← UI components
│       │   └── ... (UI parts)
│       ├── sounds/                        ← Audio alerts
│       │   └── ... (sound files)
│       └── tasks/                         ← Background tasks
│           └── ... (task files)
├── THEMES/
└── WIDGETS/
    ├── ... (other widgets)
    ├── rf2_dashboard/                     ⭐ NEW FOLDER
    │   └── main.lua                       ← Dashboard widget entry
    └── rf2_server/                        ⭐ NEW FOLDER
        └── main.lua                       ← Server widget entry (required!)
```

---

## File Transfer Methods

### Method 1: USB Cable (Recommended for TX16S)

```
┌─────────────────┐                      ┌──────────────┐
│  RadioMaster    │      USB Cable       │   Computer   │
│     TX16S       │◄────────────────────►│              │
│                 │                      │              │
│  MENU > RADIO   │                      │  SD Card     │
│  SETUP > USB    │                      │  appears as  │
│  Mode: Storage  │                      │  drive       │
└─────────────────┘                      └──────────────┘

Steps:
1. Connect USB cable
2. Set USB Mode to "Storage (SD)" on radio
3. SD card mounts as drive on computer
4. Copy files directly
5. Safely eject
6. Exit USB mode on radio
```

### Method 2: SD Card Reader

```
┌─────────────────┐                      
│  RadioMaster    │    Remove card       
│     TX16S       │───────────┐          
│                 │           │          
│  [SD Card Slot] │           ▼          
│   (Right side)  │    ┌──────────┐      ┌──────────────┐
└─────────────────┘    │ MicroSD  │─────►│  Card Reader │
                       │   Card   │      │      +       │
                       └──────────┘      │   Computer   │
                                         └──────────────┘
Steps:
1. Power off TX16S
2. Remove SD card (right side slot)
3. Insert into card reader
4. Connect to computer
5. Copy files
6. Safely eject
7. Insert card back into TX16S
```

---

## Widget Setup Visual Flow

### Step-by-Step Widget Configuration

```
1. Select Model
┌─────────────────────────────────────┐
│  MAIN MENU                          │
│                                     │
│  ► Model: Heli 550  [SELECT]        │
│    Model: Airplane                  │
│    Model: Quad                      │
└─────────────────────────────────────┘
           │
           ▼
2. Enter Model Setup
┌─────────────────────────────────────┐
│  MODEL MENU                         │
│                                     │
│    MODEL SETUP                      │
│  ► SCREEN SETUP     [PRESS]         │
│    TELEMETRY                        │
│    MIXES                            │
└─────────────────────────────────────┘
           │
           ▼
3. Select Screen Layout
┌─────────────────────────────────────┐
│  SCREEN SETUP                       │
│                                     │
│  Layout:                            │
│  ► [Full Screen]    [SELECT]        │
│    [Split 2x1]                      │
│    [Grid 4x2]                       │
└─────────────────────────────────────┘
           │
           ▼
4. Configure Main Widget Zone
┌─────────────────────────────────────┐
│  WIDGET ZONE 1                      │
│                                     │
│  Current: None                      │
│  ► Select Widget... [TAP]           │
└─────────────────────────────────────┘
           │
           ▼
5. Choose rf2_dashboard
┌─────────────────────────────────────┐
│  SELECT WIDGET                      │
│                                     │
│    Clock                            │
│    Timer                            │
│  ► rf2_dashboard    [SELECT]        │
│    rf2_server                       │
│    Battery                          │
└─────────────────────────────────────┘
           │
           ▼
6. Add Server Widget (Required!)
┌─────────────────────────────────────┐
│  WIDGET ZONE 2 (can be small)       │
│                                     │
│  Current: None                      │
│  ► Select Widget... [TAP]           │
│                                     │
│  Choose: rf2_server  [SELECT]       │
└─────────────────────────────────────┘
           │
           ▼
7. Exit to Main Screen
┌─────────────────────────────────────┐
│  📊 RF2 Dashboard Active!           │
│                                     │
│  [Dashboard displays here]          │
│  - Shows RF2 logo if no connection  │
│  - Shows live data when connected   │
└─────────────────────────────────────┘
```

---

## Widget Layout Examples

### Full Screen Layout (Recommended)
```
┌──────────────────────────────────────────────┐
│                                              │
│                                              │
│                                              │
│          RF2 DASHBOARD WIDGET                │
│           (Full Screen View)                 │
│                                              │
│        Main telemetry display area           │
│                                              │
│                                              │
│                                              │
└──────────────────────────────────────────────┘
```

### Split Layout with Server Widget
```
┌──────────────────────────────────────────────┐
│                                              │
│         RF2 DASHBOARD WIDGET                 │
│          (Main Display)                      │
│                                              │
│                                              │
├──────────────────────┬───────────────────────┤
│    Other Widget      │   rf2_server          │
│    (Timer, etc)      │   (Background)        │
└──────────────────────┴───────────────────────┘
```

### Multiple Zones Layout
```
┌───────────────────────┬──────────────────────┐
│                       │                      │
│   RF2 DASHBOARD       │   Timer / Clock      │
│   (Main View)         │                      │
│                       │                      │
├───────────────────────┼──────────────────────┤
│  rf2_server           │   Battery Widget     │
│  (Hidden/Small)       │                      │
└───────────────────────┴──────────────────────┘
```

---

## Troubleshooting Decision Tree

```
Widget not appearing in widget list?
│
├─► Are files in correct folders?
│   │
│   ├─► NO  → Copy files to correct locations
│   │        (see file structure diagram above)
│   │
│   └─► YES → Continue to next check
│
├─► Is EdgeTX version 2.11.0 or higher?
│   │
│   ├─► NO  → Update EdgeTX firmware
│   │        Download from: github.com/EdgeTX/edgetx
│   │
│   └─► YES → Continue to next check
│
└─► Did you restart the radio?
    │
    ├─► NO  → Power off, wait 5 seconds, power on
    │
    └─► YES → Check Lua Console for errors
             (MENU > RADIO SETUP > Lua Console)
```

```
Widget shows black screen or error?
│
├─► Did you add BOTH widgets?
│   │
│   ├─► NO  → Add rf2_server widget (required!)
│   │        Both rf2_dashboard AND rf2_server needed
│   │
│   └─► YES → Continue to next check
│
├─► Check Lua Console for errors
│   │
│   └─► Shows error → Note error message, check:
│          - Missing files in SCRIPTS/RF2-dashboards/
│          - Corrupted files (re-download)
│          - File permissions
│
└─► Still black? → Re-download all files and reinstall
```

```
No telemetry data showing?
│
├─► Is RF2 flight controller powered on?
│   │
│   ├─► NO  → Power on your helicopter/aircraft
│   │
│   └─► YES → Continue to next check
│
├─► Is radio link active (ELRS/CRSF)?
│   │
│   ├─► NO  → Check radio binding and connection
│   │
│   └─► YES → Continue to next check
│
├─► Is telemetry enabled on model?
│   │
│   └─► Check: MENU > MODEL SETUP > TELEMETRY
│        Enable telemetry if disabled
│
└─► Check flight controller telemetry output
    │
    └─► Verify in Rotorflight Configurator:
         Telemetry output is enabled and configured
```

---

## Quick Reference: Required Widgets

⚠️ **CRITICAL**: You must add BOTH widgets for the dashboard to work!

| Widget Name     | Purpose                  | Required? | Visibility   |
|----------------|--------------------------|-----------|--------------|
| rf2_dashboard  | Main telemetry display   | ✅ YES    | Visible      |
| rf2_server     | Background data handler  | ✅ YES    | Can be hidden|

**Common Mistake**: Adding only rf2_dashboard without rf2_server
- Result: Black screen or error
- Fix: Add rf2_server widget to any widget zone (even a small one)

---

## System Requirements Summary

| Component          | Requirement                           | Check Method                    |
|-------------------|---------------------------------------|---------------------------------|
| Radio Model       | TX16S, TX12, X10/X10S, X12S, etc     | Physical radio model            |
| Screen Type       | Color screen                          | Visual inspection               |
| EdgeTX Version    | 2.11.0 minimum (2.11.3+ recommended) | MENU > RADIO SETUP > VERSION   |
| SD Card           | MicroSD (any size, 4GB+ recommended) | Check SD slot                   |
| Flight Controller | Rotorflight 2.x                      | Rotorflight Configurator        |
| Telemetry Link    | ELRS, CRSF, or compatible            | Radio model settings            |

---

## Installation Checklist

Print or reference this checklist during installation:

- [ ] **Step 1**: Download RF2-dashboards from GitHub
- [ ] **Step 2**: Extract ZIP file to computer
- [ ] **Step 3**: Connect TX16S SD card to computer
  - [ ] Via USB cable (USB Mode: Storage), OR
  - [ ] Via SD card reader
- [ ] **Step 4**: Copy SCRIPTS folder
  - [ ] Verify: `SD:/SCRIPTS/RF2-dashboards/` exists
  - [ ] Verify: `rf2_dashboard.lua` is inside
- [ ] **Step 5**: Copy WIDGETS folder
  - [ ] Verify: `SD:/WIDGETS/rf2_dashboard/main.lua` exists
  - [ ] Verify: `SD:/WIDGETS/rf2_server/main.lua` exists
- [ ] **Step 6**: Safely disconnect SD card
- [ ] **Step 7**: Restart radio (if using USB cable)
- [ ] **Step 8**: Select model for dashboard
- [ ] **Step 9**: Enter SCREEN SETUP
- [ ] **Step 10**: Choose screen layout
- [ ] **Step 11**: Add rf2_dashboard widget to main zone
- [ ] **Step 12**: Add rf2_server widget to any zone
- [ ] **Step 13**: Exit to main screen
- [ ] **Step 14**: Verify widget appears (RF2 logo)
- [ ] **Step 15**: Connect to flight controller to see live data

✅ **Installation Complete!**

---

## Additional Notes

### Widget Updates
To update RF2-dashboards to a newer version:
1. Download new version from GitHub
2. **Backup** your existing `SCRIPTS/RF2-dashboards/` folder
3. Replace files with new version
4. Restart radio
5. Widget settings are usually preserved

### Multiple Models
You can add the RF2 dashboard to multiple models:
- Each model can have its own widget layout
- The same SCRIPTS and WIDGETS folders are shared
- No need to copy files multiple times

### Performance Tips
- Keep SD card defragmented (use SD Card Formatter tool)
- Use a quality, fast SD card (Class 10 or better)
- Regularly check for widget updates on GitHub
- Monitor Lua memory usage in Lua Console

---

For detailed explanations and troubleshooting, see: [Full Installation Guide](INSTALLATION.md)
