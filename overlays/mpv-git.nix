# overlays/mpv-git.nix
#
# Git-snapshot MPV built from the source locked by the `mpv-src` flake input.
# Keep this derivative close to nixpkgs' mpv-unwrapped so it inherits its
# dependency, Meson-option, and platform-maintenance changes.

pkgs-unstable: mpv-src: final: prev:

let
  pkgs = pkgs-unstable;
  version = "0.41.0-nightly";
in
{
  mpv-git-unwrapped = pkgs.mpv-unwrapped.overrideAttrs (oldAttrs: {
    pname = "mpv-git";
    inherit version;

    src = mpv-src;

    NIX_CFLAGS_COMPILE =
      (oldAttrs.NIX_CFLAGS_COMPILE or "") + " -O2 -pipe -march=native";

    postPatch = ''
      # Avoid embedding build-time dependency paths in the compiled-in
      # CONFIGURATION string; doing so can create an out/dev output cycle.
      configurationCount="$(
        grep -c -E \
          "^[[:space:]]*conf_data\\.set_quoted\\('CONFIGURATION'," \
          meson.build
      )"

      if [ "$configurationCount" -ne 1 ]; then
        echo "mpv-git: expected exactly one CONFIGURATION assignment in meson.build" >&2
        grep -n -C 2 "CONFIGURATION" meson.build >&2 || true
        exit 1
      fi

      sed -i -E \
        "s|^[[:space:]]*conf_data\\.set_quoted\\('CONFIGURATION',.*|conf_data.set_quoted('CONFIGURATION', '<omitted>')|" \
        meson.build

      pushd TOOLS
      mv mpv_identify.sh mpv_identify
      patchShebangs *.py *.sh
      mv mpv_identify mpv_identify.sh
      popd

      echo -n ${pkgs.lib.escapeShellArg version} > MPV_VERSION
    '';

    # Nixpkgs' check expects `mpv --help` to report exactly `${version}`.
    # That is not reliable for a source snapshot without Git metadata.
    dontVersionCheck = true;

    meta = oldAttrs.meta // {
      changelog = "https://github.com/mpv-player/mpv/commits/master";
      description = "${oldAttrs.meta.description} (git snapshot)";
    };
  });

  mpv-git = pkgs.mpv.override {
    mpv-unwrapped = final.mpv-git-unwrapped;
    youtubeSupport = false;
  };
}