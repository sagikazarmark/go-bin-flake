{ lib, stdenv, fetchzip, installShellFiles }:

stdenv.mkDerivation rec {
  pname = "golantci-lint-bin";
  version = "1.45.2";

  src =
    let
      inherit (stdenv.hostPlatform) system;

      selectSystem = attrs: attrs.${system} or (throw "Unsupported system: ${system}");

      suffix = selectSystem {
        x86_64-linux = "linux-amd64";
        aarch64-linux = "linux-arm64";
        i686-linux = "linux-386";
        x86_64-darwin = "darwin-amd64";
        aarch64-darwin = "darwin-arm64";
      };
      sha256 = selectSystem {
        x86_64-linux = "sha256-WVrWxtreTAZDUbwwn0EXA+RX+P+7ehgGs9jucTMzQn8=";
        aarch64-linux = "sha256-FGMEm3RIcRaAlePo9ockfWBA7riVlVuGmInqFR4GA6s=";
        i686-linux = "sha256-8T7L0JIoYy5rvpGoMkvWdcQG7tIuttLB6Bku7Z7E+RQ=";
        x86_64-darwin = "sha256-tZD+zc9Un0uVtWMqu23K4W0iWKD7DC2UyvdNhR4O07k=";
        aarch64-darwin = "sha256-wrlmnezBtjjPLukGBXGvTiVfbfy7IlwpPjp+5Lsschc=";
      };
    in
      fetchzip {
        inherit sha256;

        url = "https://github.com/golangci/golangci-lint/releases/download/v${version}/golangci-lint-${version}-${suffix}.tar.gz";
      };

  dontConfigure = true;
  dontBuild = true;
  dontStrip = stdenv.isDarwin;

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    runHook preInstall
    install -D golangci-lint $out/bin/golangci-lint
    runHook postInstall
  '';

  postInstall = ''
    installShellCompletion --cmd golangci-lint \
      --bash <($out/bin/golangci-lint completion bash) \
      --fish <($out/bin/golangci-lint completion fish) \
      --zsh <($out/bin/golangci-lint completion zsh)
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/golangci-lint version | grep v${version}
    runHook postInstallCheck
  '';

  dontPatchELF = true;
  dontPatchShebangs = true;
}
