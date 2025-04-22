import os
import subprocess
import re
from datetime import datetime

def generate_filename(phase, major, minor, extension='py'):
    base_name = "digitAI"

    phase_map = {
        'alpha': 'a',
        'a': 'a',
        'beta': 'b',
        'b': 'b',
        'release': 'r',
        'r': 'r'
    }
    phase_tag = phase_map.get(phase.lower())
    if not phase_tag:
        raise ValueError("Phase must be 'alpha', 'beta', or 'release'")

    version_string = f"{major}.{minor}"
    filename = f"{base_name}-{phase_tag}{version_string}.{extension}"
    return filename, phase_tag

def create_version_file(file_path):
    os.makedirs(os.path.dirname(file_path), exist_ok=True)
    with open(file_path, 'w') as script_file:
        script_file.write("# DigitAI Python Script\n")
    print(f"✅ File created: {file_path}")

def append_to_changelog(file_path, phase, major, minor, description):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    phase_title = phase.capitalize()
    version = f"{major}.{minor}"
    description_str = description if description != "None" else "No description"

    section_header = f"## {phase_title}"
    log_entry = f"""
### v{version}
- **Created:** {timestamp}  
- **File:** `{file_path}`  
- **Description:** {description_str}
"""

    changelog_path = "CHANGELOG.md"
    if not os.path.exists(changelog_path):
        with open(changelog_path, 'w') as changelog_file:
            changelog_file.write(f"# DigitAI Changelog\n\n{section_header}\n\n{log_entry.strip()}\n")
    else:
        with open(changelog_path, 'r') as changelog_file:
            changelog_contents = changelog_file.read()

        if section_header not in changelog_contents:
            changelog_contents += f"\n\n{section_header}\n"

        changelog_contents += f"\n{log_entry.strip()}\n"

        with open(changelog_path, 'w') as changelog_file:
            changelog_file.write(changelog_contents)

    print("📝 Markdown changelog updated.")

def git_commit_version(file_path, commit_message):
    try:
        subprocess.run(["git", "add", file_path], check=True)
        subprocess.run(["git", "add", "CHANGELOG.md"], check=True)
        subprocess.run(["git", "commit", "-m", commit_message], check=True)
        print("✅ Git commit created.")
    except subprocess.CalledProcessError:
        print("⚠️ Git commit failed. Are you in a Git repo?")

def get_latest_version(phase):
    changelog_path = "CHANGELOG.md"
    if not os.path.exists(changelog_path):
        return None

    with open(changelog_path, 'r') as changelog_file:
        changelog_text = changelog_file.read()

    phase_title = phase.capitalize()
    pattern = rf"## {phase_title}\n\n((?:### v[0-9]+\.[0-9]+.*?\n)+)"
    match = re.search(pattern, changelog_text, re.DOTALL)
    if not match:
        return None

    section = match.group(1)
    version_entries = re.findall(r"### v([0-9]+)\.([0-9]+)", section)
    if not version_entries:
        return None

    parsed_versions = [(int(maj), int(minor)) for maj, minor in version_entries]
    parsed_versions.sort(reverse=True)
    return parsed_versions[0]

# Main program
if __name__ == "__main__":
    print("🚀 DigitAI Version Manager (No Rewrite Tag)")

    selected_phase = input("Phase (alpha, beta, release): ")
    latest_version = get_latest_version(selected_phase)

    if latest_version:
        suggested_major = latest_version[0]
        suggested_minor = latest_version[1] + 1
        print(f"✔️ Latest for {selected_phase}: v{latest_version[0]}.{latest_version[1]}")
        print(f"Suggested: v{suggested_major}.{suggested_minor}")
    else:
        suggested_major = 0
        suggested_minor = 1
        print("ℹ️ No previous versions found. Starting from v0.1")

    major_input = input(f"Major version number [{suggested_major}]: ") or str(suggested_major)
    minor_input = input(f"Minor version number [{suggested_minor}]: ") or str(suggested_minor)
    description_input = input(f"Required: description of intended change:")

    try:
        versioned_filename, phase_tag = generate_filename(
            phase=selected_phase,
            major=major_input,
            minor=minor_input
        )

        folder_map = {'a': 'alpha', 'b': 'beta', 'r': 'release'}
        target_folder = folder_map.get(phase_tag)
        full_file_path = os.path.join(target_folder, versioned_filename)

        print(f"\n🔧 Generated filename: {full_file_path}")
        create_version_file(full_file_path)
        append_to_changelog(full_file_path, selected_phase, major_input, minor_input, description_input)

        if os.path.exists(".git"):
            confirm_commit = input("Commit this change to Git? (y/n): ")
            if confirm_commit.lower() == 'y':
                commit_msg = f"Add {versioned_filename} (Phase {selected_phase}, v{major_input}.{minor_input})"
                git_commit_version(full_file_path, commit_msg)
        else:
            print("💡 No Git repo detected. Skipping commit.")

    except ValueError as val_err:
        print(f"❌ Error: {val_err}")
