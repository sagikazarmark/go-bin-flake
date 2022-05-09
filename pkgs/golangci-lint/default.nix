{ lib, stdenv, fetchzip, installShellFiles }:

stdenv.mkDerivation rec {
  pname = "golantci-lint-bin";
  version = "1.46.0";

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
        x86_64-linux = "sha256-+mhLuSNeKW85psf6LlvArjNko1ZQ6gGoaAauCY/BW6A=";
        aarch64-linux = "sha256-qiFwa5YwYuQjkxwq2JhJiFxquaZudRvH8bFZfnm4Mus=";
        i686-linux = "sha256-MB0LFtfOYkI/Emr+vfoxjpFsjaTfBAkJAEjgT9mmpoI=";
        x86_64-darwin = "sha256-DDzm//wT+ZXNvA8Tpq9wP7R7WsUwGbeJXjuiHY1jdtw=";
        aarch64-darwin = "sha256-HEARl7T915enWVQ58Dqx+thuE8/ijukh0Yf3Ws/nVgo=";
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
