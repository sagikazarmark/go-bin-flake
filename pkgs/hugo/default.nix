{ lib, stdenv, fetchzip, installShellFiles }:

stdenv.mkDerivation rec {
  pname = "hugo-bin";
  version = "0.97.3";

  src =
    let
      inherit (stdenv.hostPlatform) system;

      selectSystem = attrs: attrs.${system} or (throw "Unsupported system: ${system}");

      suffix = selectSystem {
        x86_64-linux = "Linux-64bit";
        # https://github.com/gohugoio/hugo/issues/8257
        # aarch64-linux = "Linux-ARM64";
        x86_64-darwin = "macOS-64bit";
        aarch64-darwin = "macOS-ARM64";
      };
      sha256 = selectSystem {
        x86_64-linux = "sha256-Ayet5mYIBSy8GCynBgyvuud4727n6A73vpMUJQQkTi8=";
        # https://github.com/gohugoio/hugo/issues/8257
        # aarch64-linux = "sha256-FGMEm3RIcRaAlePo9ockfWBA7riVlVuGmInqFR4GA6s=";
        x86_64-darwin = "sha256-dfYYrWDJTRA/JQrqugMmXNC2pFZZVQB52epHEb8wwjQ=";
        aarch64-darwin = "sha256-1LsyypnXsU2x/ZzOvwwAlJbEsSF87uHE69ObXHX0f4k=";
      };
    in
      fetchzip {
        inherit sha256;

        url = "https://github.com/gohugoio/hugo/releases/download/v${version}/hugo_extended_${version}_${suffix}.tar.gz";

        stripRoot = false;
      };

  dontConfigure = true;
  dontBuild = true;
  dontStrip = stdenv.isDarwin;

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    runHook preInstall
    install -D hugo $out/bin/hugo
    runHook postInstall
  '';

  postInstall = ''
    $out/bin/hugo gen man
    installManPage man/*
    installShellCompletion --cmd hugo \
      --bash <($out/bin/hugo completion bash) \
      --fish <($out/bin/hugo completion fish) \
      --zsh <($out/bin/hugo completion zsh)
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/hugo version
    runHook postInstallCheck
  '';

  dontPatchELF = true;
  dontPatchShebangs = true;
}
