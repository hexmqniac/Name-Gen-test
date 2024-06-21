import random

def get_lines(file_path):
    try:
        with open(file_path) as file:
            return [line.strip() for line in file]
    except FileNotFoundError:
        print(f"File '{file_path}' not found.")
        return []

adjectives = get_lines("adjectives")
creatures = get_lines("creatures")

def seq():
    return '{:04d}'.format(random.randint(9999, 99999))

def generate_name(adjectives, creatures):
    ad = random.choice(adjectives) if adjectives else "Unknown"
    cr = random.choice(creatures) if creatures else "Unknown"
    sequence = seq()
    return f"{ad}_{cr}-{sequence}"

def get_number_of_names():
    while True:
        try:
            user_input = int(input("Enter the amount of names to generate: "))
            if user_input < 1:
                print("Please enter a number greater than zero.")
            else:
                return user_input
        except ValueError:
            print("Invalid input. Please enter a valid number.")

num_names = get_number_of_names()
names = [generate_name(adjectives, creatures) for _ in range(num_names)]

file_name = "fnamefile"
with open(file_name, "a") as file:
    for name in names:
        file.write(name + "\n")

print(f'Generated names have been saved to {file_name}')