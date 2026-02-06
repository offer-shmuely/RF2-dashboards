# Installation Guide - RadioMaster TX16S

Step-by-step guide for installing RF2-dashboards widget on RadioMaster TX16S.

## Prerequisites

- RadioMaster TX16S (or compatible EdgeTX color screen radio)
- EdgeTX v2.11.3 or higher
- Rotorflight v2.2 flight controller
- USB cable

To check EdgeTX version: `MENU > RADIO SETUP > ABOUT > version`

## Installation Steps

### 1. Download the Widget

1. Visit https://github.com/offer-shmuely/RF2-dashboards
2. Click **Code** → **Download ZIP**
3. Extract the ZIP file

### 2. Copy Files to SD Card

**Connect via USB:**
- Connect TX16S to computer via USB cable
- On the radio: `MENU > RADIO SETUP > USB Mode: Storage (SD)`
- SD card will appear as a drive on your computer

**Copy Files:**
```
SD CARD/
├── SCRIPTS/
│   └── RF2-dashboards/    ← Copy entire folder from download
└── WIDGETS/
    ├── rf2_dashboard/     ← Copy from download
    └── rf2_server/        ← Copy from download
```

**Important**: Copy both `SCRIPTS/RF2-dashboards/` and `WIDGETS/rf2_dashboard/` + `WIDGETS/rf2_server/`

Safely eject the SD card from your computer.

### 3. Add Widgets to Your Model

1. Power on TX16S and select your model
2. Press **MENU** → **SCREEN SETUP** (or **WIDGETS**)
3. Select a screen layout (recommend "Full screen" for main widget)
4. Tap widget zone → **Select widget** → Choose **rf2_dashboard**
5. **IMPORTANT**: Add **rf2_server** widget to the top-bar in a small layout
   - Both widgets are required for the dashboard to work
   - The rf2_server widget shows green dots when communicating with the flight controller

### 4. Configure (Optional)

Long-press the rf2_dashboard widget → **Widget settings** to configure:
- **Dashboard style**: Choose between different dashboard layouts (Style 1, Style 2, Post-flight)
- **Color themes**: Select color scheme for the dashboard
- **Auto-switch to post-flight**: Enable/disable automatic switch to summary after landing
- **Reserve capacity**: Set battery reserve percentage (0-40%)

### 5. Verify Installation

**Without Connection**: Widget displays RF2 logo with "No Connection"

**With Connection**: Connect Rotorflight flight controller to see live telemetry:
- Battery voltage/current
- RPM (head speed)
- Temperature
- GPS data (if available)
- The rf2_server widget will display green dots indicating active communication

## Dashboard Styles

**Style 1:**  
![Style 1](https://github.com/user-attachments/assets/e64ba49f-81d0-454a-ad93-c7a7bf33ffdf)

**Style 2:**  
![Style 2](https://github.com/user-attachments/assets/db48e464-5c2c-479f-8128-add91d624189)

## Troubleshooting

**Widget not in list?**
- Verify files in correct folders: `SD:/WIDGETS/rf2_dashboard/main.lua` and `SD:/WIDGETS/rf2_server/main.lua`
- Restart radio
- Check EdgeTX version ≥ 2.11.3

**Black screen or error?**
- Add both `rf2_dashboard` AND `rf2_server` widgets
- Check Lua console: `MENU > RADIO SETUP > Lua CONSOLE` for errors

**No telemetry data?**
- Power on flight controller
- Check telemetry enabled: `MENU > MODEL SETUP > TELEMETRY`
- Verify radio link active

**Widget disappeared after EdgeTX update?**
- Known issue with EdgeTX < 2.11.3
- Update to EdgeTX 2.11.3+ (recommended)
- Re-add widgets if needed

## Additional Resources

- [Project Wiki](https://github.com/offer-shmuely/RF2-dashboards/wiki)
- [GitHub Issues](https://github.com/offer-shmuely/RF2-dashboards/issues)
- [EdgeTX Documentation](https://edgetx.org/)

---

**Compatible with**: TX16S, X10/X10S, X12S, and other EdgeTX color screen radios

For questions or issues, visit the [GitHub repository](https://github.com/offer-shmuely/RF2-dashboards).
