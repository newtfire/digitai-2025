# DigitAI Version Manager

A simple Python tool to create consistent versioned files for the DigitAI project, organize them by development phase, and automatically track all changes in a Markdown changelog.

---

## 📦 Features
- 📁 Folder structure by phase (`alpha/`, `beta/`, `release/`)
- 🧠 **Auto-suggests** the next version based on `CHANGELOG.md`
- 📓 Automatically generates and updates a `CHANGELOG.md` in Markdown
- ✅ Optional Git commit for the versioned file and changelog

## DigitAI Python Versioning Rules
* Stages: 
    * *alpha* stage includes all code as we are learning, prior to the implementation of a functional AI bot.
    * *beta* stage includes code related to a functional, if flawed interactive generative AI system. Beta stage should include a system beyond terminal conversation, including interaction over a localhost web interface.
* Major and minor version numbers
    * Increment a version number iff the file represents a paradigmatic break with previous versions, implementing entirely new functions, for example. Eg. `a1` to `a2`
    * Increment a minor version number when making a significant change to improve functionality, including adding new library to develop an existing code strategy. Eg. `a1.1` to `a1.2`
    * Optional: -r1, -r2: Eg. `a1.1-r1` to `a1.1-r2`: Apply "r numbers" if the change is relatively small, but worth documenting.
* Always add a description of your change so it is added to the Changelog. This is similar to making a meaningful git commit and will help us track the history of our thinking.

---

## 🚀 Usage

1. Run the script:
   ```bash
   python digitai_version_manager
   ```

2. Enter details when prompted:
   - Phase: `alpha`, `beta`, or `release`
   - It will display the latest version and suggest the next one
   - Accept or override the suggested major and minor numbers
   - Add a short description

3. Confirm Git commit if desired.

---

## 🔤 File Naming Format
```
digitAI-[phase][major.minor].py
```

## Example Filenames
```
digitAI-a1.0.py
digitAI-a1.1.py
digitAI-b1.0.py
digitAI-r1.0.py
```

---

## 🧠 Smart Versioning

When you choose a phase, the script:
- Reads `CHANGELOG.md`
- Finds the latest version
- Suggests the next minor version

Example prompt:
```
Phase (alpha, beta, release): alpha
✔️ Latest for alpha: v1.2
Suggested: v1.3
```

---

## 📘 Changelog Output Example
```markdown
## Alpha

### v1.3
- **Created:** 2025-04-08 21:55:00  
- **File:** `alpha/digitAI-a1.3.py`  
- **Description:** Improved async support
```

---

## 📂 Project Structure
```
digitai-version-manager/
├── alpha/
├── beta/
├── release/
├── digitai_version_manager.py
├── CHANGELOG.md
└── README.md
```
