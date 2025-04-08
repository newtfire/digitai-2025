import os
import subprocess
import re
from datetime import datetime

def generate_filename(phase, major, minor, rewrite=None, extension='py'):
    base = "digitAI"

    phase_tag = {
        'alpha': 'a',
        'a': 'a',
        'beta': 'b',
        'b': 'b',
        'release': 'r',
        'r': 'r'
    }.get(phase.lower())

    if not phase_tag:
        raise ValueError("Phase must be 'alpha', 'beta', or 'release'")

    version_tag = f"{major}.{minor}"
    rewrite_tag = f"-r{rewrite}" if rewrite is not None else ""

    filename = f"{base}-{phase_tag}{version_tag}{rewrite_tag}.{extension}"
    return filename, phase_tag

def create_file(path):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w') as f:
        f.write("# DigitAI Python Script\n")
    print(f"✅ File created: {path}")

def append_changelog(path, phase, major, minor, rewrite, description):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    phase_title = phase.capitalize()
    version = f"{major}.{minor}"
    rewrite_str = f"Rewrite {rewrite}" if rewrite != "None" else "No rewrite"
    description_str = description if description != "None" else "No description"

    section_header = f"## {phase_title}"
    log_entry = f"""
### v{version} ({rewrite_str})
- **Created:** {timestamp}  
- **File:** `{path}`  
- **Description:** {description_str}
"""

    changelog_path = "CHANGELOG.md"
    if not os.path.exists(changelog_path):
        with open(changelog_path, 'w') as log:
            log.write(f"# DigitAI Changelog\n\n{section_header}\n\n{log_entry.strip()}\n")
    else:
        with open(changelog_path, 'r') as log:
            contents = log.read()

        if section_header not in contents:
            contents += f"\n\n{section_header}\n"

        contents += f"\n{log_entry.strip()}\n"

        with open(changelog_path, 'w') as log:
            log.write(contents)

    print("📝 Markdown changelog updated.")

def git_commit(path, message):
    try:
        subprocess.run(["git", "add", path], check=True)
        subprocess.run(["git", "add", "CHANGELOG.md"], check=True)
        subprocess.run(["git", "commit", "-m", message], check=True)
        print("✅ Git commit created.")
    except subprocess.CalledProcessError:
        print("⚠️ Git commit failed. Are you in a Git repo?")

def get_latest_version(phase):
    changelog_path = "CHANGELOG.md"
    if not os.path.exists(changelog_path):
        return None

    with open(changelog_path, 'r') as file:
        changelog_text = file.read()

    phase_title = phase.capitalize()
    pattern = rf"## {phase_title}\n\n((?:### v[0-9]+\.[0-9]+.*?\n)+)"
    match = re.search(pattern, changelog_text, re.DOTALL)
    if not match:
        return None

    section = match.group(1)
    entries = re.findall(r"### v([0-9]+)\.([0-9]+) \(Rewrite (\d+)\)", section)
    if not entries:
        return None

    entries = [(int(maj), int(minor), int(rw)) for maj, minor, rw in entries]
    entries.sort(reverse=True)
    return entries[0]

# Main program
if __name__ == "__main__":
    print("🚀 DigitAI Version Manager")

    phase = input("Phase (alpha, beta, release): ")
    latest = get_latest_version(phase)

    if latest:
        suggested_major = latest[0]
        suggested_minor = latest[1] + 1
        suggested_rewrite = 1
        print(f"✔️ Latest for {phase}: v{latest[0]}.{latest[1]} (Rewrite {latest[2]})")
        print(f"Suggested: v{suggested_major}.{suggested_minor} (Rewrite {suggested_rewrite})")
    else:
        suggested_major = 0
        suggested_minor = 1
        suggested_rewrite = 1
        print("ℹ️ No previous versions found. Starting from v0.1 (Rewrite 1)")

    major = input(f"Major version number [{suggested_major}]: ") or str(suggested_major)
    minor = input(f"Minor version number [{suggested_minor}]: ") or str(suggested_minor)
    rewrite = input(f"Rewrite number [{suggested_rewrite}]: ") or str(suggested_rewrite)
    desc = input("Optional description (e.g., parser, cleanup): ")

    try:
        filename, phase_tag = generate_filename(
            phase=phase,
            major=major,
            minor=minor,
            rewrite=int(rewrite)
        )

        folder_map = {'a': 'alpha', 'b': 'beta', 'r': 'release'}
        folder = folder_map.get(phase_tag)
        full_path = os.path.join(folder, filename)

        print(f"\n🔧 Generated filename: {full_path}")
        create_file(full_path)
        append_changelog(full_path, phase, major, minor, rewrite, desc or "None")

        if os.path.exists(".git"):
            do_commit = input("Commit this change to Git? (y/n): ")
            if do_commit.lower() == 'y':
                message = f"Add {filename} (Phase {phase}, v{major}.{minor}, Rewrite {rewrite})"
                git_commit(full_path, message)
        else:
            print("💡 No Git repo detected. Skipping commit.")

    except ValueError as e:
        print(f"❌ Error: {e}")
