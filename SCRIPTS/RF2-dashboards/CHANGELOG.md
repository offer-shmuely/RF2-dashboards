# Changelog

All notable changes to RF2-dashboard will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.2.14] - 2026-01
- Add top-bar when widget layout doesn't include one
- Improve dashboard selection logic
- Enable transition from post-flight dashboard to regular dashboard on arm/disarm
- Reset telemetry min/max values 4 seconds after connection (in addition to flight start)
- Show warning message for EdgeTX versions below 2.11.3 (the widget used to disapear)
- unified color for warning on post-flight dashboard

---

## [2.2.13] - 2026-01

### Added
- **Capacity Audio Alerts**: Play audio notifications when:
    - Capacity drops by 10%
    - Capacity below 20% (every 10 seconds)
    - Capacity below 30% (every 20 seconds)
- **Dynamic Status Bar**: Enhanced scrolling status bar with automatic alerts
- **Post-Flight Dashboard**: Added dashboard_post_1 for post-flight analysis

### Changed
- Enhanced flight stage detection logic
- Improved min/max telemetry value handling
- Reset min/max values automatically when flight starts

### Fixed
- Fixed issue where model image (not craft image) was not displayed

---

## [2.2.12]

### Added
- **Post-Flight Summary Dashboard**: Added comprehensive flight statistics display
- **Auto-Switch to Summary**: Automatically switches to summary view (post-flight dashboard) after landing
- **Reserve Capacity Setting**: Configurable reserve capacity (0-40%) for those who prefer to fly to 0%
- **Enhanced Flight Stage Detection**: Added new ON_AIR_PENDING state for improved flight phase tracking
- **Min/Max Telemetry Tracking**: Track min/max values for telemetry sensors to display on post-flight dashboard (replaces problematic telemetry sensor reset)

### Fixed
- Fixed unnecessary warning when connecting to MSP

### Known Issues
- Model images based on EdgeTX name are not displayed (images based on flight controller name work correctly)

---

## [2.2.11]

**Tested on**: TX16S, X10S, and TX15

### Added
- Continued separation of MSP vs Telemetry code
- Capacity announcements - voice alerts every 10% of capacity used
- Flight phase detection (pre-flight/in-flight/post-flight) in preparation for end-of-flight summary
- Display flight count (requires version 2.3.x snapshot)
- Display total model airtime (requires version 2.3.x snapshot)

### Known Issues
- Model images based on EdgeTX name are not displayed (images based on flight controller name work correctly)
- Unnecessary warning appears when connecting to MSP, even when arming is not requested

---

**Download**: https://github.com/offer-shmuely/RF2-dashboards
