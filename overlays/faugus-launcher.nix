pkgs-unstable: final: prev: {
  faugus-launcher = pkgs-unstable.faugus-launcher.overrideAttrs (oldAttrs: rec {
    version = "2.3.0";

    src = pkgs-unstable.fetchFromGitHub {
      owner = "Faugus";
      repo = "faugus-launcher";
      tag = version;
      hash = "sha256-fD4mvz4zSYzyp9MCTKjYvaYMa/Hc7IRrirnF/GNF6p8=";
    };
  });
}
