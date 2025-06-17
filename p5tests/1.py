import json
import re
from lxml import etree
import os

INPUT = "../p5subset.xml"
OUTPUT = "data/processed/chunks.jsonl"
NS = {"tei": "http://www.tei-c.org/ns/1.0"}

def clean_text(text):
    return re.sub(r"\s+", " ", text or "").strip()

def extract_attributes(spec):
    attrs = []
    for att in spec.findall(".//tei:attDef", namespaces=NS):
        name = att.get("ident")
        desc_el = att.find("tei:desc", namespaces=NS)
        desc = clean_text(desc_el.text) if desc_el is not None else ""
        if name:
            attrs.append(f"{name} ({desc})" if desc else name)
    return attrs

def extract_examples(spec):
    examples = []
    for ex in spec.findall(".//tei:exemplum", namespaces=NS):
        content = "".join(ex.itertext()).strip()
        if content:
            examples.append(content)
    return examples

def extract_children(spec):
    children = []
    for member in spec.findall(".//tei:content//tei:elementRef", namespaces=NS):
        name = member.get("key")
        if name:
            children.append(name)
    return children

def extract_classes(spec):
    classes = []
    for member in spec.findall(".//tei:classes//tei:memberOf", namespaces=NS):
        key = member.get("key")
        if key:
            classes.append(key)
    return classes

def main():
    os.makedirs("data/processed", exist_ok=True)

    tree = etree.parse(INPUT)
    root = tree.getroot()
    element_specs = root.findall(".//tei:elementSpec", namespaces=NS)

    with open(OUTPUT, "w", encoding="utf-8") as out:
        for spec in element_specs:
            ident = spec.get("ident", "unknown")
            module = spec.get("module", "unknown")

            gloss_el = spec.find(".//tei:gloss", namespaces=NS)
            desc_el = spec.find(".//tei:desc", namespaces=NS)

            gloss = clean_text(gloss_el.text) if gloss_el is not None else ""
            desc = clean_text(desc_el.text) if desc_el is not None else ""

            attributes = extract_attributes(spec)
            examples = extract_examples(spec)
            children = extract_children(spec)
            classes = extract_classes(spec)

            text_parts = []

            full_text = "\n".join(text_parts)
            url = f"https://tei-c.org/release/doc/tei-p5-doc/en/html/ref-{ident}.html"

            entry = {
                "id": f"tei-{ident}",
                "gloss": gloss,
                "description": desc,
                "attributes": attributes,
                "examples": examples,
                "element": ident,
                "module": module,
                "url": url,
                "children": children,
                "classes": classes
            }
            out.write(json.dumps(entry) + "\n")

    print(f"✅ Extracted {len(element_specs)} enriched chunks to {OUTPUT}")

if __name__ == "__main__":
    main()