# DigitAI Version Manager

A simple Python tool to create consistent versioned files for the DigitAI project, organize them by development phase, and automatically track all changes in a Markdown changelog.

---

## 📦 Features
- 📁 Folder structure by phase (`alpha/`, `beta/`, `release/`)
- 🧠 **Auto-suggests** the next version and rewrite number based on `CHANGELOG.md`
- 📓 Automatically generates and updates a `CHANGELOG.md` in Markdown
- ✅ Optional Git commit for the versioned file and changelog

---

## 🚀 Usage

1. Run the script:
   ```bash
   python digitai_version_manager.py
   ```

2. Enter details when prompted:
   - Phase: `alpha`, `beta`, or `release`
   - It will display the latest version and suggest the next one
   - Accept or override the suggested major, minor, and rewrite numbers
   - Add a short description

3. Confirm Git commit if desired.

---

## 🔤 File Naming Format
```
digitAI-[phase][major.minor]-r[rewrite].py
```

## Example Filenames
```
digitAI-a1.0-r1.py
digitAI-a1.1-r1.py
digitAI-a1.1-r2.py
digitAI-b1.0-r1.py
```

---

## 🧠 Smart Versioning

When you choose a phase, the script:
- Reads `CHANGELOG.md`
- Finds the latest version and rewrite
- Suggests the next minor version and resets the rewrite count

Example prompt:
```
Phase (alpha, beta, release): alpha
✔️ Latest for alpha: v1.3 (Rewrite 2)
Suggested: v1.4 (Rewrite 1)
```

---

## 📘 Changelog Output Example
```markdown
## Alpha

### v1.4 (Rewrite 1)
- **Created:** 2025-04-08 21:15:00  
- **File:** `alpha/digitAI-a1.4-r1.py`  
- **Description:** Added async handler
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
