{ config, lib, pkgs, ... }:

{
  config = {
    nixpkgs.hostPlatform = "x86_64-linux";

    environment = {
      etc = {
        "foo.conf".text = ''
          launch_the_rockets = true
        '';
      };
      systemPackages = [
        pkgs.ripgrep
        pkgs.fd
        pkgs.hello
      ];
    };

    systemd.services = {
      foo = {
        enable = true;
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        wantedBy = [ "system-manager.target" ];
        script = ''
          ${lib.getBin pkgs.hello}/bin/hello
          echo "We launched the rockets!"
        '';
      };

      caddy = {
        enable = true;
        serviceConfig = {
          ExecStart = "${pkgs.caddy}/bin/caddy run --config /etc/caddy/Caddyfile";
          Restart = "always";
        };
        wantedBy = [ "multi-user.target" ];
      };
    };

    environment.etc."caddy/Caddyfile".text = ''
      {
        email jonn@zerohr.io
      }

      import /etc/caddy/sites-enabled/*
    '';

    environment.etc = {
      "caddy/sites-enabled/localhost".text = ''
        localhost {
          port 8137
          root * /var/www/8137
          file_server
          try_files {path} {path}/ /404.html
          encode gzip

          @removeIndex {
            path_regexp ^(.*/)index(?:\.html)?$
          }
          redir @removeIndex {http.regexp.1}

          handle_errors {
            @404 {
              expression {http.error.status_code} == 404
            }
            respond @404 "404 Not Found" 404
          }
        }
      '';
    };

  };
}
