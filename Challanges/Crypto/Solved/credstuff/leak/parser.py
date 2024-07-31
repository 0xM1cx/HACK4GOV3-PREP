with open('usernames.txt') as users:
    u_content = users.read().split("\n")
    with open('passwords.txt') as passes:
        p_content = passes.read().split("\n")

        creds = dict(zip(u_content, p_content))
        for key, val in creds.items():
            if key == "cultiris":
                print(f"the user {key} : {val}")
