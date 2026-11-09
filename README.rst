Personal blog based on Pelican
==============================

All commands are flake apps, run from the repository root.

Workflow:

1. Create new article: ``nix run .#new -- article-name``
2. Edit ``content/article-name.md``
3. Lint modified content: ``nix run .#lint``
4. Build the site: ``nix build`` (dev site into ``./result``)
5. Preview: ``nix run .#serve`` -> http://127.0.0.1:8000
   (pass another port: ``nix run .#serve -- 8080``)
6. Deploy: ``nix run .#publish`` (builds the production site and
   rsyncs it to door.vps:/var/www/blog)

Available apps:

* ``build``  - ``nix build --print-build-logs`` wrapper (dev site)
* ``serve``  - build dev site and serve ``./result`` on port 8000
* ``publish`` - build production site (``nix build .#prod``) and rsync to the server
* ``new``    - create a new article from a template
* ``lint``   - proselint on modified content files

``nix develop`` provides a shell with ``pelican`` and ``proselint``.
