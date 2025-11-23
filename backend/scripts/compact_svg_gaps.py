import re,os,json
from glob import glob
base='docs'
files=glob(os.path.join(base,'endpoints_*.svg'))
report={}
for f in files:
    s=open(f,encoding='utf-8').read()
    xs=[]
    for m in re.finditer(r'<g[^>]*class="cluster"[^>]*>(.*?)</g>',s,flags=re.S):
        g=m.group(0)
        pm=re.search(r'd="M([0-9\.]+),([0-9\.]+)',g)
        if pm:
            x=float(pm.group(1))
            xs.append(x)
    xs_sorted=sorted(xs)
    gaps=[xs_sorted[i+1]-xs_sorted[i] for i in range(len(xs_sorted)-1)] if len(xs_sorted)>1 else []
    maxGap=max(gaps) if gaps else 0
    report[os.path.basename(f)]={'count':len(xs_sorted),'maxGap':maxGap}
    if maxGap>220:
        scale=220.0/maxGap
        # insert transform into first <g> after <defs/>
        new_s=re.sub(r'(<defs[^>]*?/?>)\s*<g(\s|>)', lambda m: m.group(1)+"<g transform=\"scale(%s,1)\""%(round(scale,3))+m.group(2), s, count=1)
        if new_s==s:
            # try alternative simple replace
            new_s=s.replace('<defs/><g','<defs/><g transform="scale(%s,1)"'%round(scale,3),1)
        open(f,'w',encoding='utf-8').write(new_s)
        report[os.path.basename(f)]['applied_scale']=round(scale,3)

print(json.dumps(report,indent=2))
