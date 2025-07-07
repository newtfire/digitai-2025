from lxml import etree

def flatten_classes_memberof_keys(input_file, output_file):
    parser = etree.XMLParser(remove_blank_text=True)
    tree = etree.parse(input_file, parser)
    root = tree.getroot()

    # Find all <classes> elements in any namespace
    for classes_elem in root.xpath('//tei:classes', namespaces={'tei': 'http://www.tei-c.org/ns/1.0'}):
        # Find all child <memberOf> elements
        member_ofs = classes_elem.xpath('tei:memberOf', namespaces={'tei': 'http://www.tei-c.org/ns/1.0'})
        if member_ofs:
            # Extract their key attribute values
            keys = [mo.get('key') for mo in member_ofs if mo.get('key')]
            # Remove all children
            for child in member_ofs:
                classes_elem.remove(child)
            # Replace content with comma-separated keys
            classes_elem.text = ', '.join(keys)

    # Save result
    tree.write(output_file, pretty_print=True, encoding='UTF-8', xml_declaration=True)

# Usage
input_path = "p5subsetTRIMMED.xml"
output_path = "p5subset_flattened_classes.xml"
flatten_classes_memberof_keys(input_path, output_path)
