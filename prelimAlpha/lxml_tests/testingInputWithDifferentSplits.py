def start_app():
    # with open(log_file, "a") as file:
        # file.write(f"\n--- Chat started on {datetime.datetime.now()} ---\n")
    while True:
        question = input("You: ")
        if question.lower() == "xpath":
            user_input = input("Type an xPath Expression: ").strip()
            slashes = '//'
            if user_input.startswith(slashes):
                user_input.split("//")
                name1 = user_input[2:]
                name2 = user_input[3:]
                if name1:
                    print(f'{slashes}{name1}')
                if name2:
                    print(f'{slashes}{name1}{slashes}{name2}')
if __name__ == "__main__":
    start_app()