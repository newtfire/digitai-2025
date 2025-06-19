# List all unique elements
from lxml import etree

dataset_file = "../p5subset.xml"
tree = etree.parse(dataset_file)
parent_tag = 'teiHeader'

# Get all elements
# elements = tree.xpath("//*")
elements = tree.xpath(f"//*[local-name()='{parent_tag}']//*")

# Use a set to collect unique tag names (namespace stripped)
unique_tags = set()

for element in elements:
    tag = element.tag.split('}', 1)[1] if '}' in element.tag else element.tag
    unique_tags.add(tag)

# Print unique tag names
for tag in sorted(unique_tags):
    print(tag)
