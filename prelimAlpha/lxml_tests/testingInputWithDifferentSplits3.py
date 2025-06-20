# List all unique elements
from lxml import etree

dataset_file = "../teiTester-dmJournal.xml"
tree = etree.parse(dataset_file)
parent_tag = 'teiHeader'

# Get all elements
# elements = tree.xpath("//*")
elements = tree.xpath(f"//*[local-name()='{parent_tag}']//*")

def start_app():
    # with open(log_file, "a") as file:
        # file.write(f"\n--- Chat started on {datetime.datetime.now()} ---\n")
    while True:
        question = input("You: ")
        if question.lower() == "xpath":
            user_input = input("Type an xPath Expression: ").strip()
            if user_input.startswith('//'):
                tokens = [t.strip() for t in user_input.split("//") if t.strip()]
                ans = ("//" + "//".join(tokens))
                print(ans)

if __name__ == "__main__":
    start_app()
