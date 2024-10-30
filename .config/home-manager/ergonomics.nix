{ pkgs, lib, ... }:

let
  inherit (lib) mkDefault mod;
  inherit (lib.strings) toLower;

  # Function to map a hex character to its integer value
  hexCharToInt = c:
    let
      lowerC = toLower c;
    in
      if lowerC == "0" then 0 else
      if lowerC == "1" then 1 else
      if lowerC == "2" then 2 else
      if lowerC == "3" then 3 else
      if lowerC == "4" then 4 else
      if lowerC == "5" then 5 else
      if lowerC == "6" then 6 else
      if lowerC == "7" then 7 else
      if lowerC == "8" then 8 else
      if lowerC == "9" then 9 else
      if lowerC == "a" then 10 else
      if lowerC == "b" then 11 else
      if lowerC == "c" then 12 else
      if lowerC == "d" then 13 else
      if lowerC == "e" then 14 else
      if lowerC == "f" then 15 else
      abort "Invalid hex character: ${c}";

  # Function to parse a two-character hex string to an integer
  parseHex = str:
    let
      c1 = hexCharToInt (builtins.substring 0 1 str);
      c2 = hexCharToInt (builtins.substring 1 1 str);
    in
      c1 * 16 + c2;

  # Function to generate color codes based on a hash
  generateColor = name: let
    hashValue = builtins.hashString "md5" name;
    colorCode = parseHex (builtins.substring 0 2 hashValue);
  in (mod colorCode 8) + 1;

  # Get the hostname from the environment
  hostname = builtins.getEnv "HOSTNAME";

  # Generate the color for Zsh host prompt
  zshHostColor = generateColor hostname;

  # Generate colors for Bash prompt components
  hostHash = builtins.hashString "md5" hostname;

  bashUserColor = generateColor (builtins.substring 0 2 hostHash);
  bashAtColor   = generateColor (builtins.substring 2 2 hostHash);
  bashHostColor = generateColor (builtins.substring 4 2 hostHash);
  bashPathColor = generateColor (builtins.substring 6 2 hostHash);
  bashGitColor = generateColor (builtins.substring 8 2 hostHash);

in

{
  home.packages = [
    pkgs.fd
    pkgs.autocutsel
  ];

  # We use dumber bash for `mc` prompt not to glitch due to starship
  programs.bash.enable = true;
  programs.bash.enableCompletion = true;

  programs.bash.bashrcExtra = ''
    # Precomputed colors based on hostname
    user_color="\$(tput setaf ${builtins.toString bashUserColor})"
    at_color="\$(tput setaf ${builtins.toString bashAtColor})"
    host_color="\$(tput setaf ${builtins.toString bashHostColor})"
    path_color="\$(tput setaf ${builtins.toString bashPathColor})"
    git_color="\$(tput setaf ${builtins.toString bashGitColor})"
    reset_color="\$(tput sgr0)"

    # Define PS1 components with the Nix-generated colors
    ps1_date="\[\$(tput bold)\]\[\$(tput setaf 40)\]\$(date +'%a %b %d %H:%M:%S:%N')"
    ps1_user="\[''${user_color}\]\u"
    ps1_at="\[''${at_color}\]@"
    ps1_host="\[''${host_color}\]\h"
    ps1_path="\[''${path_color}\]\w"
    ps1_lambda="\[\$(tput setaf 40)\]λ\[$reset_color\]"

    # Git prompt function
    git_prompt() {
      local ref
      ref="$(git symbolic-ref -q HEAD 2>/dev/null)"
      if [ -n "$ref" ]; then
        echo "(''${ref#refs/heads/}) "
      fi
    }

    # Final PS1 export with deterministic colors
    export PS1="''${ps1_date} ''${ps1_user}''${ps1_at}''${ps1_host} ''${ps1_path} \$(git_prompt)\n''${ps1_lambda} "

    # Use vi mode in the shell
    set -o vi
  '';


  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.starship.enableBashIntegration = false;
  programs.starship.settings = {
    aws.symbol = mkDefault " ";
    battery.full_symbol = mkDefault "";
    battery.charging_symbol = mkDefault "";
    battery.discharging_symbol = mkDefault "";
    battery.unknown_symbol = mkDefault "";
    battery.empty_symbol = mkDefault "";
    cmake.symbol = mkDefault "△ ";
    conda.symbol = mkDefault " ";
    crystal.symbol = mkDefault " ";
    dart.symbol = mkDefault " ";
    docker_context.symbol = mkDefault " ";
    dotnet.symbol = mkDefault " ";
    elixir.symbol = mkDefault " ";
    elm.symbol = mkDefault " ";
    erlang.symbol = mkDefault " ";
    git_branch.symbol = mkDefault " ";
    git_commit.tag_symbol = mkDefault " ";
    git_status.format = mkDefault "([$all_status$ahead_behind]($style) )";
    git_status.conflicted = mkDefault " ";
    git_status.ahead = mkDefault " ";
    git_status.behind = mkDefault " ";
    git_status.diverged = mkDefault " ";
    git_status.untracked = mkDefault " ";
    git_status.stashed = mkDefault " ";
    git_status.modified = mkDefault " ";
    git_status.staged = mkDefault " ";
    git_status.renamed = mkDefault " ";
    git_status.deleted = mkDefault " ";
    golang.symbol = mkDefault " ";
    helm.symbol = mkDefault "⎈ ";
    hg_branch.symbol = mkDefault " ";
    java.symbol = mkDefault " ";
    julia.symbol = mkDefault " ";
    kotlin.symbol = mkDefault " ";
    kubernetes.symbol = mkDefault "☸ ";
    lua.symbol = mkDefault " ";
    nim.symbol = mkDefault " ";
    nix_shell.symbol = mkDefault " ";
    nodejs.symbol = mkDefault " ";
    openstack.symbol = mkDefault " ";
    package.symbol = mkDefault " ";
    perl.symbol = mkDefault " ";
    php.symbol = mkDefault " ";
    purescript.symbol = mkDefault "<≡> ";
    python.symbol = mkDefault " ";
    ruby.symbol = mkDefault " ";
    rust.symbol = mkDefault " ";
    status.symbol = mkDefault " ";
    status.not_executable_symbol = mkDefault " ";
    status.not_found_symbol = mkDefault " ";
    status.sigint_symbol = mkDefault " ";
    status.signal_symbol = mkDefault " ";
    swift.symbol = mkDefault " ";
    terraform.symbol = mkDefault "𝗧 ";
    vagrant.symbol = mkDefault "𝗩 ";
    zig.symbol = mkDefault " ";
  };

  # Starship Prompt
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.starship.enable
  programs.starship.enable = true;

  programs.starship.settings = {
    # See docs here: https://starship.rs/config/
    # TODO: Move symbols to another file
    directory.read_only = mkDefault " ";
    directory.fish_style_pwd_dir_length = 1; # turn on fish directory truncation
    directory.truncation_length = 2; # number of directories not to truncate

    # TODO: Move symbols to another file
    gcloud.symbol = mkDefault " ";
    gcloud.disabled = true; # annoying to always have on

    hostname.style = "bold ansi${toString zshHostColor}";

    # TODO: Move symbols to another file
    memory_usage.symbol = mkDefault " ";
    memory_usage.disabled = true; # because it includes cached memory it's reported as full a lot

    # TODO: Move symbols to another file
    shlvl.symbol = mkDefault " ";
    shlvl.disabled = false;

    username.style_user = "bold ansi${toString zshHostColor}";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting = {enable = false;};
    oh-my-zsh = {
      enable = true;
      plugins = ["docker-compose" "docker" "git" "tmux" "fzf"];
      theme = "dst";
    };
    shellAliases = {
      mc = ''
           bash -c "SHELL=/home/sweater/.nix-profile/bin/bash mc"
      '';
    };
    sessionVariables = { ZSH_THEME = "spaceship"; };
    initExtra = ''
      source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh;
      bindkey '^f' autosuggest-accept;
      bindkey -v

      # Dumb
      if [[ "$TERM" == "dumb" ]]
      then
        unsetopt zle
        unsetopt prompt_cr
        unsetopt prompt_subst
        if whence -w precmd >/dev/null; then
            unfunction precmd
        fi
        if whence -w preexec >/dev/null; then
            unfunction preexec
        fi
        PS1='$ '
      fi
    '';
  };

  programs.ripgrep.enable = true;
}
