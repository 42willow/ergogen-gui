{
  lib,
  stdenv,
  rustPlatform,
  fetchYarnDeps,
  cargo-tauri,
  glib-networking,
  nodejs,
  yarnConfigHook,
  yarnBuildHook,
  openssl,
  pkg-config,
  webkitgtk_4_1,
  wrapGAppsHook4,
}: let
  toml = (lib.importTOML ./src-tauri/Cargo.toml).package;
in
  rustPlatform.buildRustPackage (finalAttrs: {
    pname = toml.name;
    inherit (toml) version;
    src = ./.;

    cargoHash = "";

    npmDeps = fetchYarnDeps {
      yarnLock = finalAttrs.src + "/yarn.lock";
      hash = "sha256-PBhn0VTt+6rf7YTuoVf3L4a6+AoXuad4E20dWiGVOOE=";
    };

    nativeBuildInputs =
      [
        cargo-tauri.hook
        nodejs

        yarnConfigHook
        yarnBuildHook

        pkg-config
      ]
      ++ lib.optionals stdenv.hostPlatform.isLinux [wrapGAppsHook4];

    buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
      glib-networking
      openssl
      webkitgtk_4_1
    ];

    cargoRoot = "src-tauri";
    buildAndTestSubdir = finalAttrs.cargoRoot;

    preBuild = ''
      yarn --offline generate
    '';
    meta = {
      inherit (toml) description homepage;
      license = lib.licenses.liliq-p-11;
      mainProgram = toml.name;
    };
  })
