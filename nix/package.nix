{
  lib,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "fido2-smartcard-bridge";
  version = "0.1.0";
  pyproject = true;

  src = lib.sourceFilesBySuffices (lib.cleanSource ../.) [
    ".py"
    ".toml"
  ];

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    fido2
    pyscard
  ];

  meta = {
    mainProgram = "fido2-smartcard-bridge";
  };
}
