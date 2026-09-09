pkgs-unstable: final: prev: {
  faugus-launcher = pkgs-unstable.faugus-launcher.overrideAttrs (oldAttrs: rec {
    version = "2.2.2";

    src = pkgs-unstable.fetchFromGitHub {
      owner = "Faugus";
      repo = "faugus-launcher";
      tag = version;
      hash = "sha256-B2sZGnXBT9dBSGHubJ0PIP3SBlCnsBBmLruakU9vjgc=";
    };
  });
}
