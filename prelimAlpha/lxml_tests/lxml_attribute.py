# List all attributes
from lxml import etree

dataset_file = "../teiTester-dmJournal.xml"

attribute = 'xml:id'

tree = etree.parse(dataset_file)
r = tree.xpath(f'//@{attribute}')
ans = list(r)
print(ans)