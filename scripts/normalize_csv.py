import os
import glob
import pandas as pd

IN_DIR = "data/input/extracted"
OUT_DIR = "data/normalized"
os.makedirs(OUT_DIR, exist_ok=True)

files = sorted(glob.glob(os.path.join(IN_DIR, "*")))

def normalize_cell(x):
    if not isinstance(x, str):
        return x
    return (
        x.replace("\r\n", "\\n")
         .replace("\n", "\\n")
         .replace("\r", "\\n")
         .strip()
    )

for path in files:
    base = os.path.basename(path)

    # garante extensão .csv na saída
    out_name = base if base.lower().endswith(".csv") else f"{base}.csv"
    out_path = os.path.join(OUT_DIR, out_name)

    df = pd.read_csv(
        path,
        sep=";",
        dtype=str,
        engine="python",
        encoding="utf-8",
        on_bad_lines="error"
    )

    df = df.applymap(normalize_cell)

    df.to_csv(
        out_path,
        sep=";",
        index=False,
        encoding="utf-8",
        quotechar='"',
        escapechar="\\",
        lineterminator="\n"
    )

    print(f"OK {base} -> {out_name} | linhas={len(df)} cols={len(df.columns)}")