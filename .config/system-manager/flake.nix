{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, flake-utils, nixpkgs, system-manager }:

  let
    pkgs = import nixpkgs { system = "x86_64-linux"; };

  in

  {
    systemConfigs.default = system-manager.lib.makeSystemConfig {
      modules = [
        ./modules
      ];
    };

    devShell.x86_64-linux = pkgs.mkShell {
      buildInputs = [
        system-manager.packages.x86_64-linux.default
      ];
    };
  };
}
