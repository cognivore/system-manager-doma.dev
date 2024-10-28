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
      "caddy/sites-enabled/icy.memorici.de.conf".text = ''
        icy.memorici.de {
          root * /var/www/icy.memorici.de
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

      "caddy/sites-enabled/doma.dev.conf".text = ''
        doma.dev, www.doma.dev {
          root * /var/www/html/public
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

          reverse_proxy /js/p_proxy.js https://plausible.doma.dev/js/plausible.js
        }
      '';

      "caddy/sites-enabled/ctf.cdn.doma.dev.conf".text = ''
        ctf.cdn.doma.dev {
          reverse_proxy http://127.0.0.1:8354 {
            max_fails 0
          }
        }
      '';

      "caddy/sites-enabled/md110.se.conf".text = ''
        md110.se {
          reverse_proxy http://127.0.0.1:18703
        }
      '';

      "caddy/sites-enabled/draft.memorici.de.conf".text = ''
        draft.memorici.de {
          reverse_proxy http://127.0.0.1:1337
        }
      '';

      "caddy/sites-enabled/behold.memorici.de.conf".text = ''
        behold.memorici.de {
          root * /var/www/hls/hls
          file_server
        }
      '';

      "caddy/sites-enabled/zhr.staging.doma.dev.conf".text = ''
        zhr.staging.doma.dev {
          root * /var/www/zhr.staging.doma.dev/public
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

      "caddy/sites-enabled/cuake.doma.dev.conf".text = ''
        cuake.doma.dev {
          root * /var/www/cuake
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

      "caddy/sites-enabled/unity-dashboard-red.zerohr.io.conf".text = ''
        unity-dashboard-red.zerohr.io {
          reverse_proxy http://localhost:8713 {
            header_up Host {host}
            header_up X-Real-IP {remote}
            header_up X-Forwarded-For {remote}
          }
          basicauth {
            / "Restricted Content" {
              file /etc/nginx/.htpasswd
            }
          }
        }
      '';

      "caddy/sites-enabled/pipe.memorici.de.conf".text = ''
        pipe.memorici.de {
          reverse_proxy http://127.0.0.1:8080 {
            header_up Host {host}
          }
        }
      '';

      "caddy/sites-enabled/demo-host.staging.doma.dev.conf".text = ''
        demo-host.staging.doma.dev {
          reverse_proxy http://127.0.0.1:8383 {
            header_up X-Forwarded-For {remote}
          }
        }
      '';

      "caddy/sites-enabled/ucg.cdn.doma.dev.conf".text = ''
        ucg.cdn.doma.dev {
          reverse_proxy http://127.0.0.1:23410
        }
      '';

      "caddy/sites-enabled/app.zerohr.io.conf".text = ''
        app.zerohr.io {
          reverse_proxy http://127.0.0.1:16426 {
            header_up Host {host}
            header_up X-Real-IP {remote}
            header_up X-Forwarded-For {remote}
            header_up X-Forwarded-Proto {scheme}
          }
        }
      '';

      "caddy/sites-enabled/staging.app.zerohr.io.conf".text = ''
        staging.app.zerohr.io {
          reverse_proxy http://127.0.0.1:16426 {
            header_up Host {host}
            header_up X-Real-IP {remote}
            header_up X-Forwarded-For {remote}
            header_up X-Forwarded-Proto {scheme}
          }
        }
      '';
    };
  };
}
