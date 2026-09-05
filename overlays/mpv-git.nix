# overlays/mpv-git.nix
#
# A git-tracking derivative of nixpkgs' mpv-unwrapped, kept intentionally
# close to upstream's package.nix so it inherits dependency/meson-flag
# maintenance for free. Differences from upstream are commented inline
# with "DERIVATIVE:" so future-you (or future nixpkgs diffs) can spot them
# at a glance.
#
# To bump to a newer commit:
#   1. Pick a new commit SHA from https://github.com/mpv-player/mpv/commits/master
#   2. Update `gitRev` below.
#   3. Set `gitHash = lib.fakeHash;` temporarily.
#   4. Rebuild; copy the `got:` hash from the mismatch error into `gitHash`.
#   5. Rebuild again.
#
# nix build .#nixosConfigurations.nixos.pkgs.mpv-git --no-link --print-out-paths
# nix run .#nixosConfigurations.nixos.pkgs.mpv-git -- --version
#
#

pkgs-unstable: final: prev:

let
  unstable = pkgs-unstable;
  gitRev = "f5bcfb1";
  gitVersion = "0.41.0-${gitRev}";
  gitHash = "sha256-f+CuOd/SJEXCqDzF/g0rgqMB6Yd6xyUPd2F8iNJrW/o=";
in
{
  mpv-git-unwrapped = unstable.mpv-unwrapped.overrideAttrs (
    oldAttrs: {
      # DERIVATIVE: distinguish from stock mpv/mpv-unwrapped in nix-env, store paths, etc.
      pname = "mpv-git";
      version = gitVersion;

      # DERIVATIVE: track a pinned git commit instead of a tagged release.
      src = unstable.fetchFromGitHub {
        owner = "mpv-player";
        repo = "mpv";
        rev = gitRev;
        hash = gitHash;
      };

      # DERIVATIVE: upstream's postPatch assumes a release-tarball meson.build.
      # We keep the functionally-necessary shebang-patching step verbatim,
      # but replace the CONFIGURATION-string substitution (still required —
      # it prevents an out/dev output reference cycle, see comment below)
      # with a version that:
      #   (a) tries both known upstream wordings (release-tarball style and
      #       current git-master style, which have already diverged once
      #       during this package's lifetime), and
      #   (b) uses --replace-quiet instead of --replace-fail, so a future
      #       upstream wording change degrades to "cycle risk returns"
      #       rather than "build hard-fails on every rebuild until fixed".
      #   (c) writes MPV_VERSION, since fetchFromGitHub has no .git for
      #       meson's files('./MPV_VERSION') to read a real version from.
      postPatch =
        let
          # Written as ''...'' (Nix indented strings): backslash is NOT
          # special in this syntax, so these are the literal bytes as they
          # appear in meson.build. Do not "clean these up" into "..." double
          # quotes without re-deriving the escaping — see this overlay's
          # commit history / the conversation that produced it for why.
          oldConfLineTarball = ''conf_data.set_quoted('CONFIGURATION', meson.build_options())'';
          oldConfLineGit = ''conf_data.set_quoted('CONFIGURATION', meson.build_options().strip().replace('\\', '\\\\'))'';
          newConfLine = ''conf_data.set_quoted('CONFIGURATION', '<omitted>')'';
        in
        unstable.lib.concatStringsSep "\n" [
          # Don't reference compile time dependencies or create a build
          # outputs cycle between out and dev (same reasoning as upstream's
          # comment on the original line this replaces).
          ''
            substituteInPlace meson.build \
              --replace-quiet ${unstable.lib.escapeShellArg oldConfLineTarball} ${unstable.lib.escapeShellArg newConfLine} \
              --replace-quiet ${unstable.lib.escapeShellArg oldConfLineGit} ${unstable.lib.escapeShellArg newConfLine}
          ''
          # A trick to patchShebang everything except mpv_identify.sh
          # (verbatim from upstream — still correct, still needed)
          ''
            pushd TOOLS
            mv mpv_identify.sh mpv_identify
            patchShebangs *.py *.sh
            mv mpv_identify mpv_identify.sh
            popd
          ''
          # DERIVATIVE: supply the version file a release tarball would
          # normally ship, since our source has no .git for meson to
          # `git describe` against.
          ''
            echo -n ${unstable.lib.escapeShellArg gitVersion} > MPV_VERSION
          ''
        ];

      # DERIVATIVE: the upstream install check greps `mpv --help` output for
      # an exact match on `version`. Without real git metadata, mpv's
      # compiled-in version string can't be made to match an arbitrary Nix
      # `version` attribute, so the check is structurally unsatisfiable here
      # (unrelated to upstream's Darwin-specific reason for the same flag).
      dontVersionCheck = true;

      # DERIVATIVE: point changelog at a commit range instead of a release tag,
      # since v${version}-style release tags don't exist for arbitrary commits.
      meta = oldAttrs.meta // {
        changelog = "https://github.com/mpv-player/mpv/commits/${gitRev}";
        description = oldAttrs.meta.description + " (git snapshot)";
      };
    }
  );

  # Reuse nixpkgs' existing mpv wrapper machinery (scripts, umpv wiring,
  # youtube-dl flag, etc.) by swapping in our derivative as its
  # mpv-unwrapped input — same mechanism as e.g.
  # `mpv.override { mpv-unwrapped = mpv-unwrapped.override { ... }; }`
  # from the NixOS wiki, just pointed at our git build instead.
  mpv-git = unstable.mpv.override {
    mpv-unwrapped = final.mpv-git-unwrapped;
    youtubeSupport = false;
  };
}
