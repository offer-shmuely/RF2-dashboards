# RF2-dashboards

Rotorflight2 touch dashboards for EdgeTX radios (v2.11.x)

<img width="488" height="283" alt="image" src="https://github.com/user-attachments/assets/e64ba49f-81d0-454a-ad93-c7a7bf33ffdf" />
<br>
<img width="490" height="285" alt="image" src="https://github.com/user-attachments/assets/db48e464-5c2c-479f-8128-add91d624189" />


Note: The work is still work in progress, (and probably will always be 😉 )
<br>
I hope others will find it as useful as I do


# Widgets

## widget - rf2_server
background communication widget

* a must have background widget (that serve all other widget)
* it do all the communication to the FC
* should be installed on the topbar
* replace the original rf2bkg script
* replace the original rf2tlm script 
* new technology that detect elrs custom telemetry at correct order is already built-in (so no special procedure is needed for sensor discovery)

So, no need to define any scripts in special-function or custom-script anymore.

![alt text](docs/img/image-1.png)


## rf2_name
used in single-tx-model (to many heli) configuration

* display the name of the heli that currently connected (not the name of the TX model)
* when another heli connected the name automatically change 


## rf2_image
used in single-tx-model (to many heli) configuration

* display the image of the heli based on it's name
* the image should exist on /IMAGES/<craft-name>.png
* when another heli connected the image automatically change
* it is NOT the image of the model as selected in the model-settings


## rf2_dashboard - dashboard widget
a dashboard of the most needed info
* important RF2 telemetry 
* important elrs telemetry

![alt text](docs/img/image-4.png)



## Overview

RF2-dashboards is a collection of Lua scripts and widgets designed to provide comprehensive telemetry dashboards for Rotorflight 2 flight controllers on EdgeTX radio system. This project offers real-time monitoring of flight data with customizable touch-enabled interfaces.

## Features

- **Real-time Telemetry Display**: Monitor critical flight parameters including RPM, battery voltage, current, ESC temperature, and link quality
- **Touch-Enabled Dashboards**: Intuitive interface designed for modern touch-screen radios
- **Multiple Widget Support**: Modular widget system for flexible dashboard customization
- **ELRS/CRSF Custom Telemetry**: Support for ExpressLRS custom telemetry sensors
- **MSP Communication**: Direct communication with Rotorflight 2 via MSP protocol (not during the flight)
- **Profile & Rate Display**: View current PID profile and rate profile
- **Timer Integration**: Built-in flight timer with customizable display

## Widgets

The package includes the following widgets:

- **rf2_dashboard**: Main comprehensive dashboard with all telemetry data
- **rf2_capacity**: Battery capacity monitoring widget
- **rf2_name**: Craft name display widget
- **rf2_image**: Custom image display widget
- **rf2_server**: Background telemetry server widget

## Requirements

- Rotorflight 2 flight controller (version 2.2.0 or higher)
- EdgeTX with color screen
- Touch-screen display (recommended for full functionality)

## Installation

1. Download the latest release from this repository
2. Copy the `SCRIPTS` folder to the root of your radio's SD card
3. Copy the `WIDGETS` folder to the root of your radio's SD card
4. Restart your radio or reload the scripts
5. Add the widgets to your screen layout through the EdgeTX/OpenTX widget configuration

## File Structure

```
/
├── SCRIPTS/
│   └── RF2-dashboards/
│       ├── rf2.lua               # Core RF2 library
│       ├── rf2tlm.lua            # Custom telemetry decoder
│       ├── rf2tlm_sensors.lua    # Sensor definitions
│       ├── background_init.lua   # Background initialization
│       ├── MSP/                  # MSP protocol handlers
│       └── widgets/              # Widget implementations
└── WIDGETS/
    ├── rf2_dashboard/            # Main dashboard widget
    ├── rf2_capacity/             # Capacity widget
    ├── rf2_name/                 # Name widget
    ├── rf2_image/                # Image widget
    └── rf2_server/               # Server widget
```

## Usage

1. **Setup**: Configure your model to use MSP telemetry over your radio link (ELRS, Crossfire, etc.)
2. **Add Widgets**: On your radio, go to the screen setup and add the RF2 widgets you want to use
3. **Configure**: Each widget has customizable options accessible through the widget settings
4. **Fly**: The dashboard will automatically display telemetry data when your model is powered on and connected

## Configuration

Each widget offers various configuration options:

- **GUI Style**: Choose between Fancy and Modern display styles
- **Color Themes**: Customize text and background colors
- **Thresholds**: Set maximum values for current and temperature warnings
- **Display Options**: Toggle between average cell voltage and total voltage

## Version

Current version: **2.2.0**

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## Credits

- Developed for the Rotorflight community
- Compatible with EdgeTX operating systems
- ELRS custom telemetry integration

## Support

For issues, questions, or contributions, please visit the [GitHub repository](https://github.com/offer-shmuely/RF2-dashboards).

## Disclaimer

This software is provided "as is" without warranty of any kind. Always ensure your aircraft is safe to fly and follow all local regulations.


---
<br><br><br>


# Requieremns
* Rotorflight 2.1.x and above
* edgeTx 2.11.x
* color touch screen 480x272 resolution (radiomaster TX16s or similar)
* ELRS protocol (accst is supported, but need some tweeks of the sensors names)
* 
