# Is able to do xPath very well
# Preserves whether the user typed / or //
# Always rewrites XPath to ignore namespace using local-name().
# Applies local-name() transformation to each tag
# Leaves attributes (@), text(), node() etc. untouched
# Keeps text(), @attr, and wildcards (*) intact.
# Supports TEI XML or any other namespaced XML without the user needing to know namespaces.
# User Input: //div//head//date
# xPath Python Reads: //*[(local-name()='div')]//*[(local-name()='head')]//*[(local-name()='date')]

from lxml import etree
import re

dataset_file = "../teiTester-dmJournal.xml"

def convert_to_namespace_agnostic_xpath(expression): # takes the xPath entered and rewrites it so it doesn't have namespace errors
    # Match tokens split by either "/" or "//"
    tokens = re.split(r'(//|/)', expression.strip())  # keep the separators

    xpath_parts = []
    for token in tokens:
        token = token.strip()
        if token in ('/', '//'):
            xpath_parts.append(token)
        elif token == '':
            continue
        elif token.startswith('@') or token in ('text()', 'node()', '*'):
            xpath_parts.append(token)
        else:
            # Handle tag[predicate]
            match = re.match(r"([a-zA-Z0-9_\-]+)(\[.*\])?", token)
            if match:
                tag, predicate = match.groups()
                local = f"*[(local-name()='{tag}')]" #  Ignores the namespace and matches by tag name only.
                if predicate:
                    local += predicate
                xpath_parts.append(local)
            else:
                xpath_parts.append(token)

    return ''.join(xpath_parts)


def start_app():
    tree = etree.parse(dataset_file)
    root = tree.getroot()

    print("Type 'exit' to quit.")
    print("Try:  //div[@type='entry']//date/text()")

    while True:
        user_input = input("Enter XPath: ").strip()
        if user_input.lower() == "exit":
            break

        # Always convert to namespace-agnostic XPath
        xpath_expr = convert_to_namespace_agnostic_xpath(user_input)

        try:
            results = tree.xpath(xpath_expr)
            if not results:
                print("No results found.")
            else:
                for idx, result in enumerate(results, start=1):
                    if isinstance(result, etree._Element):
                        print(f"{etree.tostring(result, pretty_print=True).decode().strip()}")
                    else:
                        print(f"{result}")
        except Exception as e:
            print(f"Invalid XPath expression: {e}")

if __name__ == "__main__":
    start_app()