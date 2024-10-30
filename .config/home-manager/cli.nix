{ pkgs, ... }:

{
  home.packages = [

    pkgs.mc
    pkgs.strace

    pkgs.darcs
    pkgs.parallel
    pkgs.passveil
    pkgs.shmux

    pkgs.jq
    pkgs.curl

    pkgs.darcs
    pkgs.tmux

    pkgs.fzf
    pkgs.fzf-obc
    pkgs.sysz

    pkgs.tmuxPlugins.tmux-fzf
    pkgs.gnupg
    pkgs.pinentry-curses

  ];
}
