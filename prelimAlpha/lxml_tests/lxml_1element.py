# Get text within an element
from lxml import etree

dataset_file = "../teiTester-dmJournal.xml"

tree = etree.parse(dataset_file)

element_name = 'editor'
element_index = '1'

# Get all element's text:
elements = tree.xpath(f"//*[local-name()='{element_name}']")

# Get specific element's text:
# elements = tree.xpath(f"//*[local-name()='{element_name}'][{element_index}]")

# Collect and print unique element tag names (with namespace stripped if present)
for elements in elements:
    tag = elements.tag.split('}', 1)[1] if '}' in elements.tag else elements.tag
    text = elements.text if elements.text else ''
    print(f"{text}")
