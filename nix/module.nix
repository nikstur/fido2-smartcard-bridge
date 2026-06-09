{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.fido2-smartcard-bridge;
in
{
  options.services.fido2-smartcard-bridge = {
    enable = lib.mkEnableOption "fido2-smartcard-bridge";

    package = lib.mkPackageOption pkgs "fido2-smartcard-bridge" { };
  };

  config = lib.mkIf cfg.enable {
    services.pcscd = {
      enable = true;
      plugins = [ pkgs.ccid ];
    };

    # Allow our service to access smartcards.
    # https://wiki.archlinux.org/title/GnuPG#Using_a_smart_card_on_a_remote_client
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
          if (action.id == "org.debian.pcsc-lite.access_card" &&
              subject.isInGroup("fido2-smartcard-bridge")) {
              return polkit.Result.YES;
          }
      });
      polkit.addRule(function(action, subject) {
          if (action.id == "org.debian.pcsc-lite.access_pcsc" &&
              subject.isInGroup("fido2-smartcard-bridge")) {
              return polkit.Result.YES;
          }
      });
    '';

    # Unprivileged group to access /dev/uhid
    users.groups."uhid" = { };

    # Make /dev/uhid accessible to normal users in the uhid group.
    # Doing this via udev doesn't make much sense as the kernel module for uhid
    # is only loaded on first use of the device.
    systemd.tmpfiles.settings."10-uhid"."/dev/uhid".z = {
      mode = "0660";
      group = "uhid";
    };

    systemd.services.fido2-smartcard-bridge = {
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "notify";
        ExecStart = "${lib.getExe cfg.package}";

        # Sandboxing

        DynamicUser = true;
        User = "fido2-smartcard-bridge";
        Group = "fido2-smartcard-bridge";
        SupplementaryGroups = [ "uhid" ];

        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectClock = true;
        ProtectProc = "invisible";
        ProtectHostname = true;

        PrivateTmp = "disconnected";
        PrivateMounts = true;
        PrivateNetwork = true;
        PrivateUsers = true;

        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        IPAddressDeny = "any";
        UMask = "0077";
        ProcSubset = "pid";

        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RestrictNamespaces = true;
        RestrictAddressFamilies = [ "AF_UNIX" ];

        DevicePolicy = "closed";
        DeviceAllow = [ "/dev/uhid rw" ];
        SocketBindDeny = "any";

        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";
        # Eventually switch this to an allow list
        # SystemCallFilter = [
        #   "@basic-io"
        #   "@file-system"
        #   "@io-event"
        #   "@network-io"
        #   "@signal"
        #   "@sync"
        # ];
        SystemCallFilter = [
          "@system-service"
          "~@aio"
          "~@chown"
          "~@clock"
          "~@cpu-emulation"
          "~@debug"
          "~@ipc"
          "~@keyring"
          "~@memlock"
          "~@module"
          "~@mount"
          "~@obsolete"
          "~@pkey"
          "~@privileged"
          "~@process"
          "~@raw-io"
          "~@reboot"
          "~@resources"
          "~@sandbox"
          "~@setuid"
          "~@swap"
        ];
        CapabilityBoundingSet = [ "" ];
        AmbientCapabilities = [ "" ];
      };
    };
  };
}
