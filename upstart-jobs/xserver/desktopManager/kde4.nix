{pkgs, config, ...}:

let
  inherit (pkgs.lib) mkOption mkIf;
  cfg = config.services.xserver.desktopManager.kde;
  xorg = config.services.xserver.package;

  options = { services = { xserver = { desktopManager = {

    kde4 = {
      enable = mkOption {
        default = false;
        example = true;
        description = "Enable the kde 4 desktop manager.";
      };
    };

  }; }; }; };
in

mkIf cfg.enable {
  require = options;

  services = {
    xserver = {

      desktopManager = {
        session = [{
          name = "kde4";
          start = ''
            # Start KDE.
            export KDEDIRS=$HOME/.nix-profile:/nix/var/nix/profiles/default:${pkgs.kde42.kdelibs}:${pkgs.kde42.kdebase}:${pkgs.kde42.kdebase_runtime}:${pkgs.kde42.kdebase_workspace}
            export XDG_CONFIG_DIRS=${pkgs.kde42.kdelibs}/etc/xdg:${pkgs.kde42.kdebase_runtime}/etc/xdg:${pkgs.kde42.kdebase_workspace}/etc/xdg
            export XDG_DATA_DIRS=${pkgs.kde42.kdelibs}/share:${pkgs.kde42.kdebase}/share:${pkgs.kde42.kdebase_runtime}/share:${pkgs.kde42.kdebase_workspace}/share:${pkgs.shared_mime_info}/share
            exec ${pkgs.kde42.kdebase_workspace}/bin/startkde
          '';
        }];
      };

    };
  };

  security = {
    extraSetuidPrograms = [
      "kcheckpass"
    ];
  };

  environment = {
    extraPackages = [
      xorg.xmessage # so that startkde can show error messages
      pkgs.qt4 # needed for qdbus
      pkgs.kde42.kdelibs
      pkgs.kde42.kdebase
      pkgs.kde42.kdebase_runtime
      pkgs.kde42.kdebase_workspace
      xorg.xset # used by startkde, non-essential
    ];

    etc = [
      { source = ../../../etc/pam.d/kde;
        target = "pam.d/kde";
      }
      { source = "${pkgs.xkeyboard_config}/etc/X11/xkb";
        target = "X11/xkb";
      }
    ];
  };
}