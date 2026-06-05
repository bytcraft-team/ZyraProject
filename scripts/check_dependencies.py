import pathlib
import re

root = pathlib.Path(r"c:/Project/FlutterProjects/zyra")
imports = set()
for path in (root / 'lib').rglob('*.dart'):
    text = path.read_text(encoding='utf-8')
    for m in re.finditer(r"import\s+'package:([^/']+)/", text):
        imports.add(m.group(1))

pub_file = root / 'pubspec.yaml'
deps = set()
dev_deps = set()
section = None
for line in pub_file.read_text(encoding='utf-8').splitlines():
    stripped = line.strip()
    if stripped.startswith('dependencies:'):
        section = 'deps'
        continue
    if stripped.startswith('dev_dependencies:'):
        section = 'dev_deps'
        continue
    if section and line.startswith('  ') and ':' in stripped:
        name = stripped.split(':', 1)[0]
        if section == 'deps':
            if name != 'flutter':
                deps.add(name)
        else:
            dev_deps.add(name)
    elif stripped and not line.startswith('  '):
        section = None

missing = sorted([p for p in imports if p not in deps and p not in dev_deps and p not in {'flutter', 'dart', 'zyra'}])

print('all_imports:', sorted(imports))
print('missing:', missing)
