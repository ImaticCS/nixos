# yt-dlp nightly-channel overlay.
#
# Packages the prebuilt "yt-dlp_linux.zip" asset from
# https://github.com/yt-dlp/yt-dlp-nightly-builds/releases as `yt-dlp-nightly`
# (providing $out/bin/yt-dlp), as opposed to nixpkgs' `yt-dlp`, which always
# builds the latest *stable* tag from source (see nixpkgs
# pkgs/by-name/yt/yt-dlp/package.nix).
#
# Why yt-dlp_linux.zip specifically, and not the other release assets:
#   - `yt-dlp` (no suffix)      -> "zipimport" build, needs a system Python.
#   - `yt-dlp_linux`            -> PyInstaller "onefile" build. Works, but
#                                  self-extracts to a temp dir on every run.
#   - `yt-dlp_linux.zip`        -> PyInstaller "onedir" build, unpacked. No
#                                  self-extraction overhead and no built-in
#                                  self-updater to fight with Nix. This is
#                                  what this overlay uses.
#
# Inspecting the zip (unzip -l) shows it is NOT wrapped in a single
# top-level directory: it extracts directly to `_internal/` (bundled
# CPython + shared libs + extension modules) and a `yt-dlp_linux` ELF
# binary that must sit next to `_internal/`. The PyInstaller bootloader
# finds `_internal` at runtime by resolving its own path (/proc/self/exe),
# not via rpath, so the only Nix-side jobs are:
#   1. keep the binary and _internal/ together in one output directory;
#   2. patch ELF interpreters/rpaths with autoPatchelfHook so they work
#      outside FHS (checked: everything the binary and its .so files need
#      beyond plain glibc -- libz, libssl, libffi, etc. -- is already
#      bundled inside _internal/, so no extra buildInputs are required for
#      that part).
#
# CAVEAT: this installs a binary named `yt-dlp`, same as nixpkgs' `yt-dlp`.
# Don't install both at once (system profile / home-manager) or you'll get
# a collision -- pick one. If you want both side by side, remove the
# `ln -s ... yt-dlp` line below and use `yt-dlp-nightly` as the command.
#
# Updating: version + hash are pinned for reproducibility (Nix needs a
# fixed hash for fetchzip). Run ./yt-dlp-nightly-update.sh next to this
# file to bump both to the latest nightly release, or call
# `pkgs.yt-dlp-nightly.updateScript` via your usual update tooling.

final: prev: {
  yt-dlp-nightly = prev.callPackage (
    {
      lib,
      stdenvNoCC,
      fetchzip,
      autoPatchelfHook,
      makeWrapper,
      atomicparsley,
      ffmpeg-headless,
      rtmpdump,
      # Override with `node`, `bun`, `quickjs`, or `quickjs-ng` to use a
      # different default JS runtime for full YouTube support (mirrors the
      # `jsRuntime` option on nixpkgs' own yt-dlp package).
      jsRuntime ? final.deno,
      atomicparsleySupport ? true,
      ffmpegSupport ? true,
      rtmpSupport ? true,
      javascriptSupport ? true,
    }:

    stdenvNoCC.mkDerivation (finalAttrs: {
      pname = "yt-dlp-nightly";
      # yt-dlp-nightly-builds tags releases as a UTC build timestamp, e.g.
      # "2026.08.30.232658" -- not a "vX.Y.Z" version, and not the same
      # numbering as stable yt-dlp releases.
      version = "2026.08.30.232658";

      src = fetchzip {
        url = "https://github.com/yt-dlp/yt-dlp-nightly-builds/releases/download/${finalAttrs.version}/yt-dlp_linux.zip";
        hash = "sha256-HNRi6Y1Om1g1yEiy13Hk/aOLoH83Pr7xfGYb21OokgI=";
        # The zip has two top-level entries (_internal/, yt-dlp_linux), not
        # one wrapping directory, so there is nothing for fetchzip to strip.
        stripRoot = false;
      };

      dontUnpack = true;
      dontConfigure = true;
      dontBuild = true;

      nativeBuildInputs = [
        autoPatchelfHook
        makeWrapper
      ];

      installPhase = ''
        runHook preInstall

        instDir="$out/lib/yt-dlp-nightly"
        mkdir -p "$instDir" "$out/bin"
        cp -r --no-preserve=mode,ownership "$src"/. "$instDir"/
        chmod +x "$instDir/yt-dlp_linux"

        runHook postInstall
      '';

      # autoPatchelfHook (from nativeBuildInputs) runs here automatically
      # and patches the interpreter/rpath of yt-dlp_linux and every .so
      # under _internal/. No extra buildInputs needed: everything each
      # file needs beyond glibc is already bundled inside _internal/.
      postFixup =
        let
          extraPackages =
            lib.optional atomicparsleySupport atomicparsley
            ++ lib.optional ffmpegSupport ffmpeg-headless
            ++ lib.optional rtmpSupport rtmpdump
            ++ lib.optional javascriptSupport jsRuntime;
        in
        ''
          makeWrapper "$out/lib/yt-dlp-nightly/yt-dlp_linux" "$out/bin/yt-dlp-nightly" \
            ${lib.optionalString (extraPackages != [ ]) ''--prefix PATH : "${lib.makeBinPath extraPackages}"''}

          # Also provide it as `yt-dlp` for drop-in use. Remove this line if
          # you're installing nixpkgs' `yt-dlp` alongside this overlay.
          ln -s "$out/bin/yt-dlp-nightly" "$out/bin/yt-dlp"
        '';

      passthru.updateScript = ./yt-dlp-nightly-update.sh;

      meta = {
        description = "yt-dlp nightly channel build (prebuilt PyInstaller onedir binary, no auto-update)";
        homepage = "https://github.com/yt-dlp/yt-dlp-nightly-builds";
        changelog = "https://github.com/yt-dlp/yt-dlp-nightly-builds/releases/tag/${finalAttrs.version}";
        license = lib.licenses.unlicense;
        platforms = [ "x86_64-linux" ];
        mainProgram = "yt-dlp";
      };
    })
  ) { };
}
