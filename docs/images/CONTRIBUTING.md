# Contributing Screenshots for Installation Guide

Thank you for your interest in contributing screenshots to the RF2-dashboards installation guide!

## Why Screenshots are Needed

The installation guide currently uses placeholder documentation files (`.md` files) instead of actual images. Real screenshots from RadioMaster TX16S or similar EdgeTX radios will:
- Help new users understand the installation process visually
- Reduce confusion about UI navigation
- Make the guide more accessible to visual learners
- Improve the overall quality of the documentation

## What Screenshots are Needed

See **[images/PLACEHOLDER_LIST.md](images/PLACEHOLDER_LIST.md)** for the complete list of needed screenshots.

### Priority Screenshots (Most Important)

1. **GitHub Download** (`01-github-download.png`)
   - Screenshot of the GitHub repo showing the Code → Download ZIP button
   - Easy to capture from the web

2. **Widget Selection** (`06-widget-select.png`, `07-rf2-dashboard-select.png`, `08-rf2-server-select.png`)
   - Shows the widget selection interface in EdgeTX
   - Shows rf2_dashboard and rf2_server in the widget list

3. **Connected Display** (`11-connected.png`)
   - The dashboard showing actual telemetry data
   - Can use existing screenshots if available

4. **No Connection** (`10-no-connection.png`)
   - The dashboard when no telemetry is received
   - We already have the RF2 logo image

### Nice to Have Screenshots

5. **EdgeTX Menu Navigation** (`02-usb-mode.png`, `03-model-setup.png`, `04-screen-setup.png`)
   - Shows various EdgeTX menus
   - Helps users navigate the radio

6. **Layout Selection** (`05-layout-selection.png`)
   - Widget zone layout options

7. **Widget Settings** (`09-widget-settings.png`)
   - Configuration screen for the widget

8. **Lua Console** (`12-lua-console.png`)
   - Useful for troubleshooting section

## How to Capture Screenshots

### Method 1: Take Photos of Radio Screen (Easiest)

If you don't have screenshot capability on your radio:

1. **Setup**:
   - Clean the screen
   - Good lighting (avoid reflections)
   - Hold camera/phone steady
   - Fill the frame with the screen

2. **Capture**:
   - Take multiple shots
   - Ensure text is readable
   - No glare or reflections

3. **Edit** (optional):
   - Crop to show just the screen
   - Adjust brightness/contrast if needed
   - Don't over-edit - keep it realistic

### Method 2: EdgeTX Screenshot Function (Best Quality)

Some EdgeTX radios support screenshots:

1. Enable screenshot function in EdgeTX
2. Take screenshots during the setup process
3. Screenshots saved to SD card `SCREENSHOTS/` folder
4. Transfer to computer

### Method 3: EdgeTX Companion Simulator (Alternative)

If you have EdgeTX Companion:

1. Use the simulator mode
2. Navigate to the desired screen
3. Take a screenshot using your computer
4. Save as PNG

## Screenshot Requirements

### Technical Requirements

- **Format**: PNG preferred, JPEG acceptable
- **Resolution**: 
  - Minimum: 480x272 (TX16S native resolution)
  - Recommended: Higher resolution if possible
  - Photos: 1920x1080 or better
- **File Size**: Reasonable (<500KB preferred, <1MB max)
- **Quality**: Clear, readable text

### Content Requirements

- **Clarity**: UI elements must be clearly visible
- **Readability**: Text must be legible
- **Relevance**: Show the specific UI element mentioned
- **Accuracy**: Match the described installation step
- **Language**: English UI preferred (but any language OK)

### Naming Convention

Follow the existing naming pattern:
- Format: `##-descriptive-name.png`
- Example: `06-widget-select.png`

See **[PLACEHOLDER_LIST.md](PLACEHOLDER_LIST.md)** for exact filenames.

## How to Submit Screenshots

### Option 1: Pull Request (Preferred)

1. **Fork the repository** on GitHub
2. **Clone your fork** to your computer
3. **Add screenshots** to `docs/images/` directory
   - Use the exact filenames from PLACEHOLDER_LIST.md
   - Replace the `.md` placeholder files with `.png` images
4. **Commit changes**: `git commit -m "Add screenshots for installation guide"`
5. **Push to your fork**: `git push`
6. **Create Pull Request** from your fork to main repository

### Option 2: GitHub Issue

1. **Create a new issue** on GitHub
2. **Title**: "Screenshots for Installation Guide"
3. **Attach images** to the issue (drag and drop)
4. **List which screenshots** you're providing (with filenames)
5. Maintainer will add them to the repository

### Option 3: Direct Contact

If you're not comfortable with GitHub:
- Contact the repository maintainer
- Share screenshots via other means (Discord, email, etc.)
- Maintainer will add them with proper attribution

## Quality Checklist

Before submitting, verify:

- [ ] Image is clear and focused
- [ ] Text is readable
- [ ] No personal information visible (model names, etc. - OK to have)
- [ ] Correct filename according to PLACEHOLDER_LIST.md
- [ ] PNG or JPEG format
- [ ] Reasonable file size
- [ ] Shows the relevant UI element

## Attribution

Contributors who provide screenshots will be:
- Credited in commit messages
- Acknowledged in documentation
- Listed as contributors on GitHub (if using pull request)

You can optionally add a watermark or credit to your screenshots, but it's not required.

## Screenshot Alternatives

If you can't provide screenshots from TX16S specifically:

### Acceptable Alternatives

- **Other EdgeTX Radios**: X10, X12S, TX12, etc. (as long as they're color screen)
- **Similar Widgets**: Screenshots from other EdgeTX widget installation guides
- **EdgeTX Documentation**: Official EdgeTX screenshots showing UI elements
- **Simulator Screenshots**: From EdgeTX Companion

### Attribution for Alternatives

If using screenshots from other sources:
- Ensure they're licensed for reuse (CC, GPL, public domain)
- Credit the original source
- Note in submission which source they're from

## Examples of Good Screenshots

### Good Example ✅
```
- Clear focus
- Readable text
- Relevant UI element centered
- Good lighting (for photos)
- No glare or reflections
- Correct screen/menu shown
```

### Bad Example ❌
```
- Blurry or out of focus
- Glare obscuring text
- Wrong screen/menu
- Too dark or overexposed
- Irrelevant content
- Excessive personal info (if you want privacy)
```

## Placeholder Images

Until real screenshots are available, the installation guide uses:
- **Relative links** to placeholder `.md` files
- **Descriptive alt text** for accessibility
- **Image references** to existing repository images where applicable

Real screenshots will replace these placeholders incrementally.

## Questions?

If you have questions about contributing screenshots:

1. **Check** the [images/README.md](README.md) for detailed image descriptions
2. **Review** the [PLACEHOLDER_LIST.md](PLACEHOLDER_LIST.md) for the complete list
3. **Ask** in a GitHub issue or discussion
4. **Contact** the repository maintainer

## Thank You!

Every screenshot helps make the installation guide better for new users. Your contribution is valuable and appreciated! 🙏

---

**Current Status**: 
- Placeholder documentation created for 12 images
- 2 images using existing repository assets
- All other images need community contributions

**Target**: Replace all `.md` placeholders with actual `.png` screenshots

**Priority**: Widget selection and setup screenshots (most impactful for users)

---

For more information, see:
- [images/README.md](README.md) - Detailed image descriptions
- [PLACEHOLDER_LIST.md](PLACEHOLDER_LIST.md) - Complete checklist
- [../INSTALLATION.md](../INSTALLATION.md) - The installation guide using these images
