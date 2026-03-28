"""Télécharge plantuml.jar depuis GitHub (sans dépendance externe)."""
import ssl
import urllib.request

URL = "https://github.com/plantuml/plantuml/releases/download/v1.2024.8/plantuml-1.2024.8.jar"
OUT = __file__.replace("download_jar.py", "plantuml_ok.jar")

ctx = ssl.create_default_context()
with urllib.request.urlopen(URL, context=ctx, timeout=600) as r:
    data = r.read()
with open(OUT, "wb") as f:
    f.write(data)
print("OK", OUT, len(data), "bytes")
