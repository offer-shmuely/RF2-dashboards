# RF2-dashboards Documentation

Welcome to the RF2-dashboards documentation! This directory contains comprehensive guides for installing and using the RF2 telemetry dashboard widget on EdgeTX radios.

## 📖 Available Guides

### Installation Documentation

| Guide | Description | Best For |
|-------|-------------|----------|
| **[INSTALLATION.md](INSTALLATION.md)** | Complete step-by-step installation guide with detailed explanations | First-time users, detailed walkthroughs |
| **[QUICK_START.md](QUICK_START.md)** | Quick reference installation guide | Experienced users, quick reference |
| **[VISUAL_GUIDE.md](VISUAL_GUIDE.md)** | Visual diagrams, flowcharts, and ASCII art illustrations | Visual learners, understanding file structure |

### Support Documentation

| Resource | Description | Best For |
|----------|-------------|----------|
| **[FAQ.md](FAQ.md)** | Frequently asked questions and answers | Quick answers, common problems |
| **[images/](images/)** | Installation screenshots and visual aids | Reference images for installation steps |

## 🚀 Getting Started

### New Users
1. Start with **[INSTALLATION.md](INSTALLATION.md)** for complete instructions
2. Use **[VISUAL_GUIDE.md](VISUAL_GUIDE.md)** to understand file structure
3. Reference **[FAQ.md](FAQ.md)** if you encounter issues

### Experienced Users
1. Use **[QUICK_START.md](QUICK_START.md)** for rapid installation
2. Refer to **[FAQ.md](FAQ.md)** for troubleshooting

## 📋 Prerequisites

Before you begin, ensure you have:
- RadioMaster TX16S or compatible EdgeTX color screen radio
- EdgeTX 2.11.0 or higher (2.11.3+ recommended)
- Rotorflight 2.x flight controller
- Configured telemetry link (ELRS, CRSF, etc.)

## 🔗 External Resources

- **[Project Wiki](https://github.com/offer-shmuely/RF2-dashboards/wiki)** - Additional documentation
- **[GitHub Repository](https://github.com/offer-shmuely/RF2-dashboards)** - Source code and releases
- **[GitHub Issues](https://github.com/offer-shmuely/RF2-dashboards/issues)** - Bug reports and support
- **[EdgeTX Documentation](https://edgetx.org/)** - EdgeTX operating system docs
- **[Rotorflight](https://www.rotorflight.org/)** - Rotorflight firmware information

## 📝 Documentation Overview

### Installation Guide (INSTALLATION.md)
**Length**: Comprehensive (detailed)  
**Sections**:
- Prerequisites checklist
- Download instructions
- SD card structure explanation
- File installation steps (USB cable and SD card reader methods)
- Widget setup and configuration
- Verification procedures
- Comprehensive troubleshooting guide
- Additional resources and support

**When to use**: 
- First time installing the widget
- Need detailed explanations
- Want to understand the complete process
- Troubleshooting installation issues

---

### Quick Start Guide (QUICK_START.md)
**Length**: Brief (reference)  
**Sections**:
- Quick installation steps
- SD card structure diagram
- Requirements checklist
- Quick troubleshooting fixes

**When to use**:
- Already familiar with EdgeTX widgets
- Need a quick reminder
- Fast reference during installation
- Minimal reading preferred

---

### Visual Guide (VISUAL_GUIDE.md)
**Length**: Medium (visual focus)  
**Sections**:
- ASCII art file structure diagrams
- Visual installation flow
- Widget layout examples
- Troubleshooting decision trees
- Installation checklist
- Quick reference tables

**When to use**:
- Prefer visual learning
- Want to understand file structure
- Need flowcharts and diagrams
- Following step-by-step checklist

---

### FAQ (FAQ.md)
**Length**: Comprehensive (Q&A format)  
**Sections**:
- Installation questions
- Setup questions
- Telemetry questions
- Troubleshooting questions
- Technical questions
- Update questions
- Data and display questions
- Getting help

**When to use**:
- Have a specific question
- Encountered an issue
- Want quick answers
- Prefer Q&A format

---

## 🖼️ Images Directory

The `images/` directory contains:
- Screenshots from EdgeTX radios
- Installation step illustrations
- Widget display examples
- UI navigation references

Currently, some images are placeholders (marked with `.md` files). Actual screenshots from RadioMaster TX16S or similar radios are being collected. Contributions welcome!

See **[images/README.md](images/README.md)** for details on required images.

## 🤝 Contributing to Documentation

We welcome contributions to improve the documentation:

### How to Contribute

1. **Screenshots**: Take clear screenshots from RadioMaster TX16S during installation
   - See [images/PLACEHOLDER_LIST.md](images/PLACEHOLDER_LIST.md) for needed images
   - Submit via pull request or attach to an issue

2. **Documentation Improvements**: 
   - Fix typos or unclear instructions
   - Add missing information
   - Improve explanations
   - Submit pull requests

3. **Translations**: 
   - Translate guides to other languages
   - Create new language directories (e.g., `docs/es/`, `docs/de/`)

4. **Video Guides**:
   - Create installation video tutorials
   - Link them in the documentation

### Contribution Guidelines

- Keep language clear and concise
- Use consistent formatting with existing docs
- Test instructions before submitting
- Include screenshots where helpful
- Update multiple guides if making cross-cutting changes

## 📄 Document Conventions

### Formatting
- **Bold** for important terms and actions
- `Code blocks` for file paths and commands
- > Blockquotes for important notes
- Tables for structured comparisons
- Lists for steps and options

### File Paths
- Use forward slashes: `/` (not `\`)
- SD card root shown as: `SD:/` or `SD CARD ROOT/`
- Example: `SD:/SCRIPTS/RF2-dashboards/`

### Version References
- EdgeTX versions: Format as `2.11.0`, `2.11.3+`
- RF2-dashboards versions: Refer to releases or CHANGELOG

### Screenshots
- Name according to convention: `##-description.png`
- Use PNG format preferred
- Minimum 480x272 resolution (TX16S native)
- Include alt text for accessibility

## 📱 Mobile Viewing

These markdown files are optimized for viewing on:
- GitHub web interface
- GitHub mobile app
- Local markdown viewers
- Text editors with markdown preview

For best experience on mobile:
- Use GitHub mobile app
- View in "raw" mode if tables don't render properly
- Zoom in on ASCII diagrams if needed

## 🔄 Keeping Documentation Updated

These documents are maintained alongside the RF2-dashboards widget code:
- Updates when major features are added
- Corrections for EdgeTX changes
- Community feedback incorporated
- Screenshots added as available

**Last Major Update**: February 2026  
**EdgeTX Version Targeted**: 2.11.0+  
**RF2-dashboards Version**: 2.2.14+

## 📞 Getting Help

If documentation doesn't answer your question:

1. **Check the FAQ**: [FAQ.md](FAQ.md)
2. **Search Issues**: [GitHub Issues](https://github.com/offer-shmuely/RF2-dashboards/issues)
3. **Ask a Question**: Create a new issue with the "question" label
4. **Community**: Join Rotorflight and EdgeTX communities

When asking for help, include:
- Which guide you followed
- What step you're stuck on
- Radio model and EdgeTX version
- Screenshots of the issue
- Lua Console errors (if any)

---

**Repository**: [offer-shmuely/RF2-dashboards](https://github.com/offer-shmuely/RF2-dashboards)  
**License**: GNU General Public License v3.0  
**Maintained by**: Community contributors

---

*Thank you for using RF2-dashboards! Safe flying! 🚁*
