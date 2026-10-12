"""python3 /tmp/mk.py Name:x,z Name:x,z ...  -> /tmp/build_batch.lua
A spec starting with '--@base Other' reuses Other's spec: its first 'local X = rgb(...)' line (the palette) is replaced by the line after
'--@colors ', its return line is dropped, and the rest of this spec (extras + own return) is appended."""
import sys
D = "/home/user/P50DX-PROD/studio/"
kit = open(D + "Kit.lua").read()
mod = open(D + "BlockAnimal.lua").read()
def load(name):
    spec = open(f"{D}animals/{name}.lua").read()
    if spec.startswith("--@base "):
        lines = spec.splitlines()
        base = load(lines[0].split()[1]).splitlines()
        pal = next(l[len("--@colors "):] for l in lines if l.startswith("--@colors "))
        i = next(i for i, l in enumerate(base) if l.startswith("local ") and "= rgb(" in l)
        base[i] = pal
        base = [l for l in base if not l.startswith("return {name")]
        extra = [l for l in lines if not l.startswith("--@")]
        return "\n".join(base + extra)
    return spec
builds = []
for arg in sys.argv[1:]:
    name, xz = arg.split(":"); x, z = xz.split(",")
    spec = load(name)
    body = spec if "local V = Vector3.new\nlocal P = {}" in spec else kit + "\n" + spec
    builds.append(f"{{(function()\n{body}\nend)(), Vector3.new({x}, 0, {z})}}")
code = open("/tmp/build2.lua").read().replace("MODULE_SOURCE", mod).replace("BUILDS", "{" + ",\n".join(builds) + "}")
open("/tmp/build_batch.lua", "w").write(code)
print(len(code), "chars")
