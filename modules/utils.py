def load_variables_from_file(filename):
    variables = {}
    with open(filename, 'r') as file:
        for line in file:
            line = line.strip()
            if line and not line.startswith("#"):
                key, value = line.split('=', 1)
                value = value.strip().strip('"')
                variables[key.strip()] = value
    return variables
