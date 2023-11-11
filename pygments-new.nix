{ pkgs
, lib
, buildPythonPackage
, fetchPypi

# build-system
, setuptools

# tests
, pytestCheckHook
, wcag-contrast-ratio
}:

let pygments = buildPythonPackage
  rec {
    pname = "pygments";
    version = "git";
    format = "pyproject";

    src = pkgs.fetchFromGitHub {
      owner = "pygments";
      repo = "pygments";
      rev = "33c66e714e35b345ac634691488fac564589ced6";
      hash = "sha256-jNm3T5k5+CtWMXHSNd9zVCAry4JXCQnmcOd11QzAfOo=";
    };

    nativeBuildInputs = [
      setuptools
    ];

    # circular dependencies if enabled by default
    doCheck = false;

    nativeCheckInputs = [
      pytestCheckHook
      wcag-contrast-ratio
    ];

    disabledTestPaths = [
      # 5 lines diff, including one nix store path in 20000+ lines
      "tests/examplefiles/bash/ltmain.sh"
    ];

    pythonImportsCheck = [
      "pygments"
    ];

    passthru.tests = {
      check = pygments.overridePythonAttrs (_: { doCheck = true; });
    };

    meta = with lib; {
      changelog = "https://github.com/pygments/pygments/releases/tag/${version}";
      homepage = "https://pygments.org/";
      description = "A generic syntax highlighter";
      mainProgram = "pygmentize";
      license = licenses.bsd2;
      maintainers = with maintainers; [ ];
    };
  };
in pygments
