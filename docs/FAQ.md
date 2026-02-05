# Frequently Asked Questions (FAQ)

## Installation Questions

### Q: What EdgeTX radios are compatible with RF2-dashboards?

**A:** RF2-dashboards works on any EdgeTX radio with a color screen running version 2.11.0 or higher, including:
- RadioMaster TX16S (and TX16S MkII)
- RadioMaster TX12
- FrSky X10/X10S
- FrSky X12S
- Jumper T16
- And other color screen EdgeTX radios

The installation steps are similar across all radios, though this guide focuses on the TX16S.

---

### Q: Can I use this on a black and white screen radio?

**A:** No, RF2-dashboards requires a color screen. It uses visual elements and color coding that won't work properly on monochrome displays.

---

### Q: Do I need both widgets (rf2_dashboard and rf2_server)?

**A:** Yes! Both widgets are required:
- **rf2_dashboard**: The visual display widget you see on screen
- **rf2_server**: Background service that processes telemetry data

Without rf2_server, the dashboard won't work and you'll see a black screen or error.

---

### Q: Can I hide the rf2_server widget since it's not meant to be visible?

**A:** Yes! You can:
1. Place it in a very small widget zone
2. Use a layout where it's in a less visible position
3. The widget will still function even if barely visible

The server widget doesn't need to be large or prominent - it just needs to exist in the widget layout.

---

### Q: What EdgeTX version do I need exactly?

**A:** 
- **Minimum**: EdgeTX 2.11.0
- **Recommended**: EdgeTX 2.11.3 or higher
- **Warning**: Versions below 2.11.3 may show a warning message (but still work)

To check your version: `MENU > RADIO SETUP > VERSION`

---

### Q: Where can I download the latest EdgeTX version?

**A:** Visit the official EdgeTX releases page:
- https://github.com/EdgeTX/edgetx/releases

Download the appropriate firmware for your radio model and follow EdgeTX's update instructions.

---

## Setup Questions

### Q: The widget disappeared after an EdgeTX update. What happened?

**A:** This was a known issue with EdgeTX versions below 2.11.3. Solutions:
1. Update to EdgeTX 2.11.3 or higher (recommended)
2. Re-add the widgets to your model screen layout
3. The latest version of RF2-dashboards shows a warning for old EdgeTX versions

---

### Q: Can I use this widget with multiple models?

**A:** Yes! You can add the RF2 dashboard to as many models as you want:
- The SCRIPTS and WIDGETS folders are shared across all models
- Each model can have its own screen layout and widget configuration
- Widget settings may be per-model depending on the configuration

---

### Q: Do I need to copy files to each model separately?

**A:** No! You only need to copy the files once to the SD card:
- SCRIPTS/RF2-dashboards/ - copied once
- WIDGETS/rf2_dashboard/ - copied once
- WIDGETS/rf2_server/ - copied once

Then you can add the widgets to any model's screen layout without copying files again.

---

### Q: How do I switch between dashboard styles?

**A:** Configure in the widget settings:
1. Long-press on the rf2_dashboard widget
2. Select "Widget settings" or tap the settings icon
3. Choose your preferred dashboard style (Style 1, Style 2, etc.)
4. Exit to save

---

## Telemetry Questions

### Q: The widget shows "No Connection" even though my model is on. Why?

**A:** Several possible causes:

1. **Radio link not active**: Ensure your radio is bound to the receiver
2. **Telemetry not configured**: Check `MENU > MODEL SETUP > TELEMETRY`
3. **Wrong model selected**: Make sure you're on the correct model
4. **Flight controller not outputting telemetry**: Check Rotorflight Configurator settings

---

### Q: What telemetry protocols are supported?

**A:** RF2-dashboards works with:
- **CRSF** (Crossfire/ELRS) - Recommended
- **ELRS** (ExpressLRS) with custom telemetry
- Other protocols that provide Rotorflight telemetry data

The widget reads telemetry from EdgeTX sensors, so any protocol that provides the required sensors will work.

---

### Q: Do I need ELRS or specific hardware?

**A:** No specific hardware required, but:
- You need a **Rotorflight 2.x** flight controller
- You need a **telemetry-capable radio link** (ELRS, CRSF, etc.)
- The radio and receiver must be bound and configured for telemetry

---

### Q: Can I use this with Betaflight or other flight controllers?

**A:** No, RF2-dashboards is specifically designed for **Rotorflight 2.x** flight controllers. It expects Rotorflight-specific telemetry data and won't work correctly with Betaflight, iNav, or other firmware.

For Betaflight, look for Betaflight-specific EdgeTX widgets.

---

## Troubleshooting Questions

### Q: The widget shows a black screen. What's wrong?

**A:** Most common causes:

1. **Missing rf2_server widget**: Add it to any widget zone
2. **Corrupted files**: Re-download and reinstall
3. **Wrong EdgeTX version**: Update to 2.11.0+
4. **File path error**: Verify files are in correct locations

Check the Lua Console (`MENU > RADIO SETUP > Lua CONSOLE`) for error messages.

---

### Q: Where is the Lua Console and what should I look for?

**A:** Access it via: `MENU > RADIO SETUP > Lua CONSOLE`

Look for:
- **Error messages**: Indicate missing files or script errors
- **Memory usage**: High memory usage may cause issues
- **Script status**: Shows which scripts are running

Common errors:
- "File not found" → Check file paths
- "Out of memory" → Too many widgets/scripts running
- Syntax errors → Corrupted files, reinstall

---

### Q: The widget is very slow or laggy. How can I fix it?

**A:** Try these solutions:

1. **Reduce other widgets**: Running many widgets uses CPU/memory
2. **Use a faster SD card**: Class 10 or UHS-I recommended
3. **Defragment SD card**: Use SD Card Formatter tool
4. **Update EdgeTX**: Newer versions have performance improvements
5. **Restart radio**: Clears memory and resets Lua engine

---

### Q: Audio alerts don't work. What should I check?

**A:** Check these settings:

1. **Sound files installed**: `SD:/SCRIPTS/RF2-dashboards/sounds/` should have audio files
2. **Global volume**: `MENU > RADIO SETUP > AUDIO` - adjust volume
3. **Audio alerts enabled**: Check widget settings for audio options
4. **Special functions**: Some alerts may use EdgeTX special functions

---

### Q: Can I customize the dashboard layout or colors?

**A:** Some customization is available:
- **Dashboard style**: Choose from available styles in widget settings
- **Color themes**: May have theme options in settings
- **Layout modification**: Advanced users can edit Lua files (not recommended unless you know Lua)

The widget comes with preset styles designed to work well. Custom layouts require Lua programming knowledge.

---

## Technical Questions

### Q: How much SD card space does RF2-dashboards need?

**A:** The complete installation requires:
- **SCRIPTS folder**: ~500KB - 1MB
- **WIDGETS folder**: ~50-100KB
- **Total**: Less than 2MB typically

Any MicroSD card 4GB or larger is more than sufficient.

---

### Q: Does the widget use MSP or telemetry?

**A:** The current version primarily uses **telemetry sensors** from EdgeTX. Some features may use MSP (Multi-Serial Protocol) for advanced data, but basic operation relies on telemetry.

---

### Q: Can I run other widgets alongside RF2-dashboards?

**A:** Yes! You can run multiple widgets simultaneously:
- Clock/Timer widgets
- Battery monitors
- Other telemetry displays

However, keep in mind:
- More widgets = more CPU/memory usage
- May slow down the radio on older EdgeTX versions
- Test performance with your desired widget combination

---

### Q: Is there a performance difference between dashboard styles?

**A:** Generally no significant difference. Choose the style you prefer visually. If you experience lag:
- Try different styles to see if one performs better
- Reduce other running widgets
- Ensure you're using the latest EdgeTX version

---

## Update Questions

### Q: How do I update to a newer version of RF2-dashboards?

**A:** Follow these steps:

1. **Backup current installation** (optional but recommended):
   - Copy `SCRIPTS/RF2-dashboards/` to your computer
2. **Download new version** from GitHub
3. **Replace files**:
   - Delete old `SCRIPTS/RF2-dashboards/` folder
   - Copy new `SCRIPTS/RF2-dashboards/` folder
   - Replace `WIDGETS/rf2_dashboard/` and `WIDGETS/rf2_server/`
4. **Restart radio**
5. **Test**: Widget settings usually preserved

---

### Q: Will updating erase my settings?

**A:** Usually not, but it depends on the update:
- Widget settings are typically stored by EdgeTX, not the widget files
- Dashboard style preferences may be preserved
- In major updates, you might need to reconfigure some settings

Always backup before updating if you have custom configurations.

---

### Q: How do I know which version I'm running?

**A:** Check the version by:
1. Looking at the CHANGELOG.md in `SCRIPTS/RF2-dashboards/`
2. The widget may display version in the about/info screen
3. Compare your files to the latest release on GitHub

---

## Data and Display Questions

### Q: What telemetry data does the dashboard display?

**A:** The dashboard shows various flight data including:
- Battery voltage and current
- Capacity used and remaining
- RPM (head speed for helicopters)
- Temperature (ESC, motor, etc.)
- GPS data (if available)
- Flight mode
- Timer information
- And more depending on your setup

---

### Q: Can I see post-flight statistics?

**A:** Yes! RF2-dashboards includes a post-flight dashboard:
- Automatically switches after landing (configurable)
- Shows flight summary statistics
- Displays min/max values for key parameters
- Flight duration and capacity used

---

### Q: Why do some values show "---" or blank?

**A:** This means the data is not available:
- Sensor not configured in EdgeTX
- Flight controller not sending that telemetry data
- Feature not supported by your hardware
- No GPS lock (for GPS data)

Configure missing sensors in EdgeTX or check your flight controller telemetry output.

---

## Getting Help

### Q: Where can I get help if I'm still having issues?

**A:** Several resources available:

1. **Documentation**:
   - [Installation Guide](INSTALLATION.md)
   - [Visual Guide](VISUAL_GUIDE.md)
   - [Project Wiki](https://github.com/offer-shmuely/RF2-dashboards/wiki)

2. **GitHub**:
   - [Issues Page](https://github.com/offer-shmuely/RF2-dashboards/issues) - Report bugs or ask questions
   - Search existing issues for similar problems

3. **Community**:
   - Rotorflight forums and groups
   - EdgeTX community forums
   - RC groups and Discord servers

When asking for help, include:
- Radio model (e.g., TX16S)
- EdgeTX version
- RF2-dashboards version
- Description of the issue
- Screenshots if possible
- Lua Console errors (if any)

---

### Q: Can I contribute to the project?

**A:** Yes! Contributions are welcome:
- Report bugs via GitHub Issues
- Suggest features
- Contribute code improvements (pull requests)
- Help improve documentation
- Share screenshots for the installation guide
- Help other users in forums

Visit the [GitHub repository](https://github.com/offer-shmuely/RF2-dashboards) to contribute.

---

### Q: Is there a video installation guide?

**A:** Check the project wiki and README for links to video guides. If none are available yet:
- Community members may create video guides
- Consider creating one to help others!
- Share on YouTube and link in GitHub discussions

---

**Last Updated**: February 2026  
**For**: RF2-dashboards on EdgeTX 2.11+

For the latest information, visit: https://github.com/offer-shmuely/RF2-dashboards
