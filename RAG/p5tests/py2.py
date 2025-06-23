import json
import sys
def fix_json_array_to_jsonl(input_path, output_path):
    try:
        with open(input_path, "r", encoding="utf-8") as infile:
            data = json.load(infile)
        if not isinstance(data, list):
            raise ValueError(":x: Input file must contain a JSON array (a list of objects).")
        with open(output_path, "w", encoding="utf-8") as outfile:
            for obj in data:
                json_line = json.dumps(obj, ensure_ascii=False)
                outfile.write(json_line + "\n")
        print(f":white_check_mark: Success! JSONL saved to: {output_path}")
    except json.JSONDecodeError as e:
        print(f":x: JSON decode error: {e}")
    except Exception as e:
        print(f":x: Error: {e}")
# ----------- Modify these paths as needed -----------
input_file = "data/processed/chunks_with_children_classes.jsonl"  # Path to your broken file
output_file = "data/processed/chunks_with_children_classes_FIXED.jsonl"  # Desired output path
# ----------------------------------------------------
fix_json_array_to_jsonl(input_file, output_file)