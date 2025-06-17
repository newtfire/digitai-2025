def start_app():
    # with open(log_file, "a") as file:
        # file.write(f"\n--- Chat started on {datetime.datetime.now()} ---\n")
    while True:
        question = input("You: ")
        if question.lower() == "xpath":
            user_input = input("Type an xPath Expression: ").strip()
            if user_input.startswith('//') or user_input.startswith('/'):
                tokens = user_input.split("//")
                # ebb: Let's try to make the split either / or // (regex will be the way: look up how to use it).
                for t in tokens:
                    local = f"[local-name()='{t}']"
                    ans = f"//{local}"
                    # ans2 = " ".join(ans)
                    if t.strip(): # Prints not blank t
                        print(ans)
if __name__ == "__main__":
    start_app()