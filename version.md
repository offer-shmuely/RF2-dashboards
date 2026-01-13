# RF2-dashboard 


# version: v2.2.13
### New Features:
- play capacity audio when:
    - capacity drops by 10%
    - capacity below 20%, every 10 seconds
    - capacity below 30%, every 20 seconds
- new dynamic statusbar with scrolling and auto alerts
- add dashboard_post_1 for post flight analysis


### Improvements:
- enhance flight stage logic
- fixed: image of model (not craft) wasn't showed

---

# version: v2.2.12
### New Features:
* Added post-flight summary dashboard with flight statistics
* automatically switch to summary view (post flight dashboard) after landing
* Added reserve capacity setting (0-40%) for touse of you who prefer to tfly to 0%
* Improved flight stage detection with new ON_AIR_PENDING state
* track min/max for telemetry sensors, to display on post flight dashbord (instead of reset telemetry sensors that cause problems)
* fixed: Unnecessary warning when connecting to MSP

### Known Issues:
* Model images based on EdgeTX name are not displayed (images based on flight controller name work correctly)

The new version is available here:
https://github.com/offer-shmuely/RF2-dashboards

Please report any issues you encounter.


---


# version 2.2.11
I'm happy to announce that a new version of rf2-dashboard is now available!

It has been tested and runs well on TX16S, X10S, and TX15.

### New Features:
* Continued separation of MSP vs Telemetry code
* Capacity announcements - voice alerts every 10% of capacity used
* Flight phase detection (pre-flight/in-flight/post-flight) in preparation for end-of-flight summary
* Display flight count (requires version 2.3.x snapshot)
* Display total model airtime (requires version 2.3.x snapshot)

### Known Issues:
* Model images based on EdgeTX name are not displayed (images based on flight controller name work correctly)
* Unnecessary warning appears when connecting to MSP, even when arming is not requested

The new version is available here:
https://github.com/offer-shmuely/RF2-dashboards

Please report any issues you encounter.
