import re
import csv
from pathlib import Path

ROOT = Path(__file__).resolve().parent
INPUT = ROOT.parent / 'recetas-ejemplo.sql'
OUTPUT = ROOT.parent / 'receta.csv'

# Pattern to capture the INSERT INTO `receta` ... VALUES (...),(...),...; block
insert_start_re = re.compile(r"INSERT INTO `receta` \(`id_receta`, `nombre`, `url_imagen`, `ingrediente`, `preparacion`, `estado`, `id_cat`, `id_pais`, `fecha_creacion`, `id_usr`\) VALUES", re.IGNORECASE)

def extract_values_block(sql_text):
    # find the INSERT line
    m = insert_start_re.search(sql_text)
    if not m:
        return None
    start = m.end()
    i = start
    n = len(sql_text)
    in_str = False
    esc = False
    depth = 0
    # scan until we find the semicolon that ends the INSERT (when not inside a string and depth==0)
    while i < n:
        ch = sql_text[i]
        if ch == "'" and not esc:
            in_str = not in_str
        if ch == '\\' and not esc:
            esc = True
            i += 1
            continue
        else:
            esc = False
        if not in_str:
            if ch == '(':
                depth += 1
            elif ch == ')':
                if depth > 0:
                    depth -= 1
            elif ch == ';' and depth == 0:
                # end of INSERT statement
                end = i
                block = sql_text[start:end].strip()
                return block
        i += 1
    return None

# split the block by '),(' but be careful with parentheses inside strings

def split_tuples(block):
    tuples = []
    i = 0
    n = len(block)
    while i < n:
        # find opening parenthesis
        while i < n and block[i] != '(':
            i += 1
        if i >= n:
            break
        start = i
        i += 1
        depth = 1
        in_str = False
        esc = False
        while i < n and depth > 0:
            ch = block[i]
            if ch == "'" and not esc:
                in_str = not in_str
            if ch == '\\' and not esc:
                esc = True
                i += 1
                continue
            else:
                esc = False
            if not in_str:
                if ch == '(':
                    depth += 1
                elif ch == ')':
                    depth -= 1
            i += 1
        end = i
        tuples.append(block[start:end])
    return tuples


def unquote_and_unescape(s):
    # s comes like 'some text' or NULL
    if s.upper() == 'NULL':
        return ''
    if len(s) >= 2 and s[0] == "'" and s[-1] == "'":
        inner = s[1:-1]
        # replace escaped sequences from MySQL dump: \r\n => \n, \\ => \\, \' => '
        inner = inner.replace('\\r\\n', '\n')
        inner = inner.replace('\\n', '\n')
        inner = inner.replace("\\'", "'")
        inner = inner.replace('\\\"', '"')
        inner = inner.replace('\\\\', '\\')
        return inner
    return s


def parse_tuple(t):
    # t like (1, 'name', 'url', 'ingred', 'prep', 1, 4, 1, '2023-06-27', 2)
    inner = t.strip()[1:-1]
    parts = []
    cur = []
    in_str = False
    esc = False
    i = 0
    while i < len(inner):
        ch = inner[i]
        if ch == "'" and not esc:
            in_str = not in_str
            cur.append(ch)
            i += 1
            continue
        if ch == '\\' and not esc:
            esc = True
            cur.append(ch)
            i += 1
            continue
        else:
            esc = False
        if ch == ',' and not in_str:
            part = ''.join(cur).strip()
            parts.append(part)
            cur = []
            i += 1
            continue
        cur.append(ch)
        i += 1
    if cur:
        parts.append(''.join(cur).strip())
    # Now unquote and unescape textual fields
    parts = [unquote_and_unescape(p) for p in parts]
    return parts


def main():
    sql_text = INPUT.read_text(encoding='utf-8')
    block = extract_values_block(sql_text)
    if not block:
        print('No INSERT block found for receta')
        return
    tuples = split_tuples(block)
    rows = []
    for t in tuples:
        row = parse_tuple(t)
        rows.append(row)
    # debug: show number of rows and columns per row
    print(f'Parsed {len(rows)} tuples from INSERT block')
    for idx, r in enumerate(rows[:20], start=1):
        print(f' Row {idx}: cols={len(r)}')
    # write CSV header
    header = ['id_receta','nombre','url_imagen','ingrediente','preparacion','estado','id_cat','id_pais','fecha_creacion','id_usr']
    with OUTPUT.open('w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f, quoting=csv.QUOTE_MINIMAL)
        writer.writerow(header)
        for r in rows:
            writer.writerow(r)
    print(f'Written {len(rows)} rows to {OUTPUT}')

if __name__ == '__main__':
    main()
