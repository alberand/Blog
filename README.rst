Personal blog based on Pelican
==============================

Workflow:

1. Create new article `cp ./misc/template.md ./content/new_article.md`
2. `make proselint` check text with linter
3. `make html`
4. `make serve` to view the web-site on http://127.0.0.1:8000
5. `make publish` to generate production version
6. `make github` to commit and push changes
