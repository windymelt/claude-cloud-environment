import re, sys, json, os, statistics
R = "/home/user/sn-bench-results"
TOT = re.compile(r"^\[info\] Total time: (\d+) ms")
TASK = re.compile(r"^\[info\]\s+(.+?)\s*:\s+(\d+) ms")
STAGE = re.compile(r"^\[info\] ([A-Z][^:]*?) \((\d+) ms\)$")

def parse(path):
    blocks, cur, stages = [], None, []
    for line in open(path, errors="replace"):
        line = line.rstrip("\n")
        m = TOT.match(line)
        if m:
            cur = {"total": int(m.group(1)), "tasks": {}, "stages": stages}
            blocks.append(cur); stages = []; continue
        m = STAGE.match(line)
        if m:
            stages.append((m.group(1), int(m.group(2)))); continue
        m = TASK.match(line)
        if m and cur is not None:
            cur["tasks"][m.group(1)] = int(m.group(2))
    out = {}
    links = [b for b in blocks if "app / Compile / nativeLink" in b["tasks"]]
    comp = [b for b in blocks if "app / Compile / compileIncremental" in b["tasks"] and "app / Compile / nativeLink" not in b["tasks"]]
    out["compile"] = comp[0]["total"]
    for i, b in enumerate(links[:3], 1):
        out[f"link{i}"] = b["total"]
        out[f"link{i}_stages"] = b["stages"]
        out[f"link{i}_scalac"] = b["tasks"].get("app / Compile / compileIncremental", 0)
    return out

def med(xs): return statistics.median(xs)
conds = sys.argv[1:] or ["base","A","B","C","D1","D2","E1","E2","F"]
res = {}
for c in conds:
    runs = []
    for i in (1,2,3):
        p = f"{R}/{c}/run{i}.log"
        if os.path.exists(p):
            try: runs.append(parse(p))
            except Exception as e: print("parse fail", p, e)
    res[c] = runs
json.dump(res, open(f"{R}/parsed.json","w"), indent=1)
keys = ["compile","link1","link2","link3"]
base = {k: med([r[k] for r in res["base"]]) for k in keys} if len(res.get("base",[]))==3 else None
print("| cond | metric | run1 | run2 | run3 | median | vs base |")
print("|---|---|---|---|---|---|---|")
for c, runs in res.items():
    if len(runs) < 3: print(f"| {c} | incomplete ({len(runs)}) |"); continue
    for k in keys:
        v = [r[k] for r in runs]; m = med(v)
        ratio = f"{m/base[k]:.2f}x" if base and base[k] else "-"
        print(f"| {c} | {k} | {v[0]} | {v[1]} | {v[2]} | {m} | {ratio} |")
# stage medians
print()
for c, runs in res.items():
    if len(runs) < 3: continue
    for k in ("link1","link3"):
        names = []
        for r in runs:
            for n,_ in r[k+"_stages"]:
                if n not in names: names.append(n)
        parts = []
        for n in names:
            vals = [sum(v for nn,v in r[k+"_stages"] if nn==n) for r in runs]
            parts.append(f"{n}={med(vals)}")
        sc = med([r[k+"_scalac"] for r in runs])
        print(f"{c} {k}: scalac(in-task)={sc} | " + " | ".join(parts))
