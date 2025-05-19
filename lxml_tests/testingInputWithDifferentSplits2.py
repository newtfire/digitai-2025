def start_app():
    # with open(log_file, "a") as file:
        # file.write(f"\n--- Chat started on {datetime.datetime.now()} ---\n")
    while True:
        question = input("You: ")
        if question.lower() == "xpath":
            user_input = input("Type an xPath Expression: ").strip()
            slashes = '//'
            if user_input.startswith(slashes):
                e1, e2, e3, e4 = user_input.split("//")
                print(e2)
                print(e3)
                print(e4)
if __name__ == "__main__":
    start_app()