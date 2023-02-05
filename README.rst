Personal blog based on Pelican
==============================

Workflow:

1. Create new article `cp ./misc/template.md ./content/new_article.md`
2. `make proselint` check text with linter
3. `nix-build`
4. `nix-shell --run 'pelican -l -o result'`
5. View the web-site on http://127.0.0.1:8000
6. `pelican content -s publishconf.py` to generate production version
7. `make github` to commit and push changes
