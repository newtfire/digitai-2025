def start_app():
    # with open(log_file, "a") as file:
        # file.write(f"\n--- Chat started on {datetime.datetime.now()} ---\n")
    while True:
        question = input("You: ")
        if question.lower() == "xpath":
            user_input = input("Type an xPath Expression: ").strip()
            if user_input.startswith("//"):
                slashes = "//"
                remainder = user_input[2:]
                if remainder:
                    element_name = remainder
                    print(f'{slashes}{remainder}')
if __name__ == "__main__":
    start_app()