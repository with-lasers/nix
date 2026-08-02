{lib, ...}: let
  mkPair = keyName: valName: key: val: {
    "${keyName}" = key;
    "${valName}" = val;
  };
in {
  flake.lib.espanso = {
    regexes = attrs: lib.mapAttrsToList (mkPair "regex" "replace") attrs;
    triggers = attrs: lib.mapAttrsToList (mkPair "trigger" "replace") attrs;

    # Let multiple triggers return the same thing
    # It's helpful when you want to group a list of triggers, like ::iso
    mapper = attrs:
      lib.mapAttrsToList (
        replace: trigger: let
          triggers =
            if builtins.isString trigger
            then [trigger]
            else trigger;
        in {
          inherit replace triggers;
        }
      )
      attrs;

    dates = label: {
      format,
      triggers ? [],
      params ? {},
    }: {
      inherit label;
      triggers = [":date"] ++ triggers;
      replace = "{{ date }}";
      vars = [
        {
          name = "date";
          type = "date";
          params = params // {inherit format;};
        }
      ];
    };
  };

  flake.homeModules.productivity = {lib, ...}: {
    services.espanso = {
      # I set the keyboard_layout.{layout,model} in private flake
      configs.default = {
        toggle_key = "ALT";
        search_shortcut = "CTRL+ALT+SPACE";
      };

      matches.base.matches =
        []
        ++ lib.espanso.mapper {
          tldr = "TL;DR:";
          "ä" = "::a";
          "ö" = "::o";
          "ü" = "::u";
          "ß" = "::s";
          "Ä" = "::A";
          "Ö" = "::O";
          "Ü" = "::U";
        }
        ++ lib.espanso.regexes {
          " {{number}}º" = "\\s(?P<number>\\d+)o";
          " {{number}}ª" = "\\s(?P<number>\\d+)a";
        };

      matches.datetime.matches = lib.mapAttrsToList lib.espanso.dates {
        "format: 1970-W01" = {
          triggers = ["::iso" "::week"];
          format = "%G-W%V";
        };

        "format: 100 (day)".format = "%j";
        "format: 2020-Q1 (quarter)".format = "%Y-Q%q";
        "format: 01/01/1970".format = "%d/%m/%Y";
        "format: Jan 1, 1970".format = "%B %d, %Y";

        "format: 1970-01-01T11:00:00-03:00 (timestamptz)" = {
          triggers = [":dt" ":rfc3339"];
          format = "%Y-%m-%dT%H:%M:%S%:z";
        };

        "format: 1 de Janeiro de 1970 [pt-BR]" = {
          format = "%d de %B de %Y";
          params.locale = "pt-BR";
        };

        "format: 1970-01-01 (today)" = {
          format = "%Y-%m-%d";
          triggers = ["::iso" ":today"];
        };

        "format: 1970-01-01 (yesterday)" = {
          format = "%Y-%m-%d";
          triggers = ["::iso" ":yesterday"];
          params.offset = -86400;
        };

        "format: 1970-01-01 (tomorrow)" = {
          format = "%Y-%m-%d";
          triggers = ["::iso" ":tomorrow"];
          params.offset = 86400;
        };

        "format: 1970-01-01T12:34:56Z" = {
          format = "%Y-%m-%dT%H:%M:%SZ";
          triggers = [":isodatetime" ":utc"];
          params.utc = true;
        };
      };

      matches.search.matches =
        []
        ++ lib.espanso.triggers {
          "ddg//" = "https://duckduckgo.com/?q=";
          "gg//" = "https://google.com/search?q=";
          "maps//" = "https://www.google.com/maps/search/";
          "r//" = "https://www.reddit.com/search/?q=";
          "wa//" = "https://www.wolframalpha.com/input/?i=";
          "w//" = "https://en.wikipedia.org/w/?search=";
          "yt//" = "https://youtube.com/results?q=";
        }
        ++ lib.espanso.triggers {
          "mba//" = "https://musicbrainz.org/search?type=artist&query=";
          "mbid//" = "https://musicbrainz.org/mbid/";
          "mbr//" = "https://musicbrainz.org/search?type=release&query=";
          "mbrg//" = "https://musicbrainz.org/search?type=release_group&query=";
          "mbs//" = "https://musicbrainz.org/search?type=series&query=";
          "mbw//" = "https://musicbrainz.org/search?type=work&query=";
          "bp//" = "https://www.beatport.com/search?q=";
          "dza//" = "https://www.deezer.com/search/$|$/album";
          "spf//" = "https://open.spotify.com/search/";
        }
        ++ lib.espanso.triggers {
          "arch//" = "https://wiki.archlinux.org/index.php?search=";
          "dh//" = "https://hub.docker.com/search?q=";
          "gh//" = "https://github.com/search?q=";
          "np//" = "https://search.nixos.org/packages?channel=unstable&query=";
          "no//" = "https://search.nixos.org/options?channel=unstable&query=";
          "hm//" = "https://home-manager-options.extranix.com/?release=master&query=";
          "so//" = "https://stackoverflow.com/search?q=";
        }
        ++ lib.espanso.triggers {
          "h//" = "https://";
          "www//" = "https://www.";
        };

      matches.utf-8.matches = lib.espanso.mapper {
        "…" = "...";
        "←" = ".larrow";
        "→" = ".rarrow";
        "™" = ".tm";
        "☆☆☆☆☆" = [":rating-0" "::rating"];
        "★☆☆☆☆" = [":rating-1" "::rating"];
        "★★☆☆☆" = [":rating-2" "::rating"];
        "★★★☆☆" = [":rating-3" "::rating"];
        "★★★★☆" = [":rating-4" "::rating"];
        "★★★★★" = [":rating-5" "::rating"];
      };
    };
  };
}
