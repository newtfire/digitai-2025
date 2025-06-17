from lxml import etree

dataset_file = "../teiTester-dmJournal.xml"
tree = etree.parse(dataset_file)

def start_app():
    # with open(log_file, "a") as file:
        # file.write(f"\n--- Chat started on {datetime.datetime.now()} ---\n")
    while True:
        question = input("You: ")
        if question.lower() == "xpath":
            user_input = input("Type an xPath Expression: ").strip()
            xpath = 'root.xpath'
            if user_input.startswith('//'):
                tokens = user_input.split("//")
                # ebb: Let's try to make the split either / or // (regex will be the way: look up how to use it).
                for t in tokens:
                    # Get all elements
                    # elements = tree.xpath("//*")
                    # elements = tree.xpath(f"//*[local-name()='{t}']//*")
                    local = f"[local-name()="
                    eee = f"{t}]"
                    ans = ("//" + "//".join(t))
                    print(ans)
                    # path = tree.xpath(ans)
                    # print(path)
                    # Use a set to collect unique tag names (namespace stripped)
                    # unique_tags = set()

                    # for element in elements:
                        # tag = element.tag.split('}', 1)[1] if '}' in element.tag else element.tag
                        # unique_tags.add(tag)

                    # Print unique tag names
                    # for tag in sorted(unique_tags):
                        # print(tag)
if __name__ == "__main__":
    start_app()