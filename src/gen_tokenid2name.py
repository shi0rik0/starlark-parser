names = dict()

with open("../build/parser.h") as fo:
    begin_read = False
    for line in fo.readlines():
        if "enum yytokentype" in line:
            begin_read = True
            continue
        if begin_read:
            if '{' in line:
                continue
            if '}' in line:
                break
            name, idx = line.split('=')[0].strip(), line.split('=')[1].strip()
            names[name] = idx
    print(names)

print ("/*----- Print token names -----*/\n")
print ("switch (c) {")

for token_name in names.keys():
    print(f'case {token_name}:')
    if token_name == "INT":
        print(f'    printf("{token_name.lower()}(%s)\\n", yylval.string);')
    elif token_name == "IDENTIFIER" or token_name == "STRING":
        print(f'    printf("{token_name.lower()}(%s)\\n", yylval.string);')
    elif token_name == "FLOAT":
        print(f'    printf("{token_name.lower()}(%f)\\n", yylval.float_);')
    else:
        print(f'    printf("{token_name.lower()}\\n");')
    print(f'    break;')

print('}')

print ("/*-----  -----*/\n")