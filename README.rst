Personal blog based on Pelican
==============================

Workflow:

1. Create new article `cp ./misc/template.md ./content/new_article.md`
2. `make proselint` check text with linter
3. `pelican content -s pelicanconf.py -r -l`
4. View the web-site on http://127.0.0.1:8000
5. `pelican content -s publishconf.py` to generate production version
6. `make github` to commit and push changes
