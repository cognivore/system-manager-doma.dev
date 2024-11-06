{ pkgs, ... }:

{
  home.packages = [ pkgs.purescript pkgs.spago-unstable ];
}
