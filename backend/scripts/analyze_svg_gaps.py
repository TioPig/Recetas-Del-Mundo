import re,os,json
from glob import glob
base='docs'
files=glob(os.path.join(base,'endpoints_*.svg'))
results={}
for f in files:
    with open(f,encoding='utf-8') as fh:
        s=fh.read()
    xs=[]
    for m in re.finditer(r'<g[^>]*class="cluster"[^>]*>(.*?)</g>',s,flags=re.S):
        g=m.group(0)
        pm=re.search(r'd="M([0-9\.]+),([0-9\.]+)',g)
        if pm:
            x=float(pm.group(1))
            xs.append(x)
    xs_sorted=sorted(xs)
    gaps=[round(xs_sorted[i+1]-xs_sorted[i],3) for i in range(len(xs_sorted)-1)] if len(xs_sorted)>1 else []
    results[os.path.basename(f)]={'count':len(xs_sorted),'gaps':gaps,'maxGap':max(gaps) if gaps else 0}
print(json.dumps(results,indent=2))
