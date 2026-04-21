{
  description = "Ruby gem flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    nixpkgs-ruby.url = "github:bobvanderlinden/nixpkgs-ruby";
    nixpkgs-ruby.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, utils, nixpkgs-ruby }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          system = "${system}";
          overlays = [
            nixpkgs-ruby.overlays.default
          ];
        };

        kubectl = pkgs.buildGoModule rec {
          pname = "kubectl";
          version = "1.31.0";

          src = pkgs.fetchFromGitHub {
            owner = "kubernetes";
            repo = "kubernetes";
            rev = "v${version}";
            hash = pkgs.lib.fakeHash;  # replace after first build
          };

          vendorHash = null;
          subPackages = [ "cmd/kubectl" ];
          env.CGO_ENABLED = 0;
          ldflags = [
            "-s" "-w"
            "-X k8s.io/component-base/version.gitVersion=v${version}"
          ];
          doCheck = false;
        };

        helm = pkgs.buildGoModule rec {
          pname = "helm";
          version = "3.16.2";

          src = pkgs.fetchFromGitHub {
            owner = "helm";
            repo = "helm";
            rev = "v${version}";
            hash = pkgs.lib.fakeHash;  # replace after first build
          };

          vendorHash = pkgs.lib.fakeHash;  # replace after first build
          subPackages = [ "cmd/helm" ];
          env.CGO_ENABLED = 0;
          ldflags = [
            "-s" "-w"
            "-X helm.sh/helm/v3/internal/version.version=v${version}"
            "-X helm.sh/helm/v3/internal/version.gitCommit=${src.rev}"
          ];
          doCheck = false;
        };
      in
      {
        packages = {
          inherit kubectl helm;
          default = kubectl;
        };

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [ pkgs.pkg-config ];
          buildInputs = with pkgs; [
            pkgs."ruby-4.0.2"
            libyaml
            openssl
          ];

          shellHook = ''
            export GEM_HOME="$PWD/.gem"
            export GEM_PATH="$GEM_HOME"
            export PATH="$PWD/exe:$GEM_HOME/bin:$PATH"
            export BUNDLE_PATH="$GEM_HOME"
            export BUNDLE_BIN="$GEM_HOME/bin"
          '';
        };
      }
    );
}
