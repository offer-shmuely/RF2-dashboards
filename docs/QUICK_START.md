# Quick Installation Reference

## RadioMaster TX16S - EdgeTX 2.11+

### Quick Steps

1. **Download** the RF2-dashboards files from GitHub
2. **Copy** folders to SD card:
   - `SCRIPTS/RF2-dashboards/` → `SD:/SCRIPTS/RF2-dashboards/`
   - `WIDGETS/rf2_dashboard/` → `SD:/WIDGETS/rf2_dashboard/`
   - `WIDGETS/rf2_server/` → `SD:/WIDGETS/rf2_server/`
3. **Add widgets** to your model:
   - Main display: Add `rf2_dashboard` widget
   - Background service: Add `rf2_server` widget (required)
4. **Test** - Power on your helicopter to see telemetry data

### SD Card Structure
```
SD:/
├── SCRIPTS/
│   └── RF2-dashboards/    ← All script files
└── WIDGETS/
    ├── rf2_dashboard/     ← Main widget
    └── rf2_server/        ← Server widget (required)
```

### Requirements Checklist
- [ ] RadioMaster TX16S (or compatible EdgeTX color screen radio)
- [ ] EdgeTX 2.11.0 or higher
- [ ] MicroSD card
- [ ] Rotorflight 2 flight controller
- [ ] Configured telemetry link (ELRS, CRSF, etc.)

### Troubleshooting Quick Fixes

**Widget not in list?**
- Check file paths are correct
- Restart radio
- Verify EdgeTX version ≥ 2.11.0

**Black screen or error?**
- Add BOTH widgets (rf2_dashboard AND rf2_server)
- Check Lua console: MENU > RADIO SETUP > Lua CONSOLE

**No data shown?**
- Power on flight controller
- Check telemetry is configured on model
- Verify radio link is active

---

For detailed instructions with screenshots, see: [Full Installation Guide](INSTALLATION.md)
