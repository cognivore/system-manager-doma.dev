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
        email you@example.com
      }

      import /etc/caddy/sites-enabled/*
    '';

    environment.etc = {
      "caddy/sites-enabled/example.com.conf".text = ''
        example.com {
          reverse_proxy localhost:8080
        }
      '';
      "caddy/sites-enabled/another-site.conf".text = ''
        another-site.com {
          reverse_proxy localhost:9090
        }
      '';
    };
  };
}
