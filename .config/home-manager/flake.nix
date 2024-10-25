{
  description = "Home Manager configuration of sweater";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    passveil = {
      url = "github:doma-engineering/passveil";
      # Ensure passveil uses the same nixpkgs
      inputs.nixpkgs.follows = "nixpkgs";
    };
    shmux = { url = "github:doma-engineering/shmux"; };
  };

  outputs = { nixpkgs, home-manager, system-manager, passveil, shmux, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
          config.allowUnfreePredicate = (_: true);
          overlays = [ 
              (final: prev: {
                passveil = passveil.packages.${final.system}.default;
                shmux = shmux.packages.${final.system}.default;
                system-manager = system-manager.packages.${final.system}.system-manager;
              })
          ];
        };
    in {
      homeConfigurations."sweater" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./home.nix ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    };
}
