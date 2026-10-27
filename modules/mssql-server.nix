{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.mssql-server;

  setupEnabled = cfg.saPasswordFile != null;

  servicePath = with pkgs; [
    bash
    coreutils
    findutils
    gawk
    glibc.bin
    gnugrep
    gnused
    gnutar
    gzip
    hostname
    procps
    python3
    shadow
    systemd
    util-linux
  ];

  commonEnv = {
    ACCEPT_EULA = "Y";
    MSSQL_PID = cfg.edition;
    MSSQL_TCP_PORT = toString cfg.port;
    TZDIR = "${pkgs.tzdata}/share/zoneinfo";
  };

  setupScript = pkgs.writeShellScript "mssql-server-setup" ''
    export MSSQL_SA_PASSWORD="$(cat "$CREDENTIALS_DIRECTORY/sa-password")"
    exec ${cfg.package}/opt/mssql/bin/mssql-conf --noprompt setup
  '';
in
{
  options.services.mssql-server = {
    enable = lib.mkEnableOption "Microsoft SQL Server";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../packages/mssql-server.nix { };
      description = "The Microsoft SQL Server package to use.";
    };

    saPasswordFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/run/secrets/mssql-sa-password";
      description = ''
        Path to a file containing the SA password. It is read at runtime through
        systemd's credential mechanism and must not point into the Nix store.
        Required for the first start, when the SQL Server data directory has not
        been initialized yet.
      '';
    };

    edition = lib.mkOption {
      type = lib.types.str;
      default = "Developer";
      example = "Enterprise";
      description = ''
        SQL Server edition or a 25-character product key. Accepted edition
        names include Evaluation, Express, Developer, StandardDeveloper,
        Standard, EnterpriseDeveloper, Enterprise, and EnterpriseCore.
      '';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 1433;
      description = "TCP port on which SQL Server listens.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.mssql = { };

    users.users.mssql = {
      isSystemUser = true;
      group = "mssql";
      home = "/var/opt/mssql";
      createHome = false;
      shell = pkgs.bash;
      description = "Microsoft SQL Server";
    };

    systemd.tmpfiles.rules = [
      "d /opt 0755 root root -"
      "L+ /opt/mssql - - - - ${cfg.package}/opt/mssql"
      "d /var/opt/mssql 0770 mssql mssql -"
      "d /var/opt/mssql/.system 0770 mssql mssql -"
      "d /var/opt/mssql/data 0770 mssql mssql -"
      "d /var/opt/mssql/log 0770 mssql mssql -"
      "d /var/opt/mssql/log/mssql-conf 0770 mssql mssql -"
      "d /var/opt/mssql/security 0770 mssql mssql -"
      "d /var/opt/mssql/security/ca-certificates 0770 mssql mssql -"
    ];

    systemd.services.mssql-server-setup = lib.mkIf setupEnabled {
      description = "Microsoft SQL Server first-run setup";
      before = [ "mssql-server.service" ];
      after = [ "systemd-tmpfiles-setup.service" ];
      requires = [ "systemd-tmpfiles-setup.service" ];
      unitConfig.ConditionPathExists = "!/var/opt/mssql/data/master.mdf";
      environment = commonEnv;
      path = servicePath;

      serviceConfig = {
        Type = "oneshot";
        ExecStart = setupScript;
        LoadCredential = [ "sa-password:${cfg.saPasswordFile}" ];
        TimeoutStartSec = "30min";
      };
    };

    systemd.services.mssql-server = {
      description = "Microsoft SQL Server Database Engine";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target"
        "auditd.service"
      ]
      ++ lib.optional setupEnabled "mssql-server-setup.service";
      requires = lib.optional setupEnabled "mssql-server-setup.service";
      environment = commonEnv;
      path = servicePath;

      unitConfig = {
        StartLimitIntervalSec = 120;
        StartLimitBurst = 3;
      };

      serviceConfig = {
        ExecStart = "${cfg.package}/opt/mssql/bin/sqlservr";
        User = "mssql";
        WorkingDirectory = "/var/opt/mssql";
        KillMode = "process";
        TimeoutSec = "30min";
        LimitNPROC = "infinity";
        LimitNOFILE = "infinity";
        TasksMax = "infinity";
        UMask = "007";
        Restart = "on-failure";
      };
    };
  };
}
