{ pkgs, ... }:

{
  home.packages = [
    pkgs.nixpkgs-fmt
    pkgs.nixfmt
];
}
