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

    environment.etc = {
      "caddy/Caddyfile".text = ''
	  {
	    email jonn@zerohr.io
	    admin 127.0.0.1:8313
	  }

	  import /etc/caddy/sites-enabled/*
	'';

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

              # Match the specific request path
              rewrite /js/p_proxy.js /js/plausible.js

              # Proxy all requests to the upstream server
              reverse_proxy https://plausible.doma.dev
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
              basic_auth {
	        guest $2a$14$ENKV34cqasJ8VT5uApM8gOYkinwwdUlnAR6PT7fpFwCipaQtwKfRq
              }
              reverse_proxy http://localhost:8713 {
                header_up Host {host}
                header_up X-Real-IP {remote}
                header_up X-Forwarded-For {remote}
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
      };
  };
}
