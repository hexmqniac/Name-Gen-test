def find_duplicates_in_file(filename):
    seen = set()
    duplicates = set()
    with open(filename, 'r') as f:
        for line in f:
            name = line.strip()  # Remove any surrounding whitespace or newline characters
            if name in seen:
                duplicates.add(name)
            else:
                seen.add(name)
    return duplicates

filename = 'fnamefile'
duplicates = find_duplicates_in_file(filename)
if duplicates:
    print("Duplicates found:")
    for name in duplicates:
        print(name)
else:
    print("No duplicates found")