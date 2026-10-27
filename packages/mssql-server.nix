{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  bash,
  coreutils,
  findutils,
  gawk,
  gnugrep,
  gnused,
  gnutar,
  gzip,
  openssl,
  krb5,
  e2fsprogs,
  openldap,
  numactl,
  pam,
  sssd,
  systemd,
  util-linux,
  python3,
  procps,
}:

stdenvNoCC.mkDerivation {
  pname = "mssql-server";
  version = "17.0.5005.3";

  src = fetchurl {
    url = "https://packages.microsoft.com/ubuntu/24.04/mssql-server-2025/pool/main/m/mssql-server/mssql-server_17.0.5005.3-1_amd64.deb";
    hash = "sha256-JJQUPta5khwHjlbAw4d+UBTWqZj8GZV/5oV6NKc3Bh4=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    bash
    coreutils
    findutils
    gawk
    gnugrep
    gnused
    gnutar
    gzip
    python3
    procps
  ];

  buildInputs = [
    openssl
    (lib.getLib krb5)
    e2fsprogs
    openldap
    numactl
    pam
    sssd
    systemd
    (lib.getLib util-linux)
    stdenv.cc.cc.lib
  ];

  autoPatchelfFlags = [ "--preserve-origin" ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -a opt $out/opt
    mkdir -p $out/share
    cp -a usr/share/doc usr/share/man $out/share/

    install -Dm644 usr/lib/systemd/system/mssql-server.service \
      $out/lib/systemd/system/mssql-server.service
    ${gnused}/bin/sed -i \
      "s#ExecStart=/opt/mssql/bin/sqlservr#ExecStart=$out/opt/mssql/bin/sqlservr#" \
      $out/lib/systemd/system/mssql-server.service

    mkdir -p $out/share/licenses/mssql-server
    zcat usr/share/doc/mssql-server/license/1033/license.txt.gz \
      > $out/share/licenses/mssql-server/LICENSE
    chmod 644 $out/share/licenses/mssql-server/LICENSE

    for f in \
      $out/opt/mssql/bin/*.sh \
      $out/opt/mssql/bin/mssql-conf \
      $out/opt/mssql/lib/mssql-conf/*.sh \
      $out/opt/mssql/lib/mssql-conf/*.py
    do
      [ -f "$f" ] || continue

      ${gnused}/bin/sed -i -E \
        -e "s#(^|[^[:alnum:]_/])/opt/mssql#\1$out/opt/mssql#g" \
        -e "s#/bin/bash#${bash}/bin/bash#g" \
        -e "s#/bin/tar#${gnutar}/bin/tar#g" \
        -e "s#/bin/rm#${coreutils}/bin/rm#g" \
        -e "s#/bin/mv#${coreutils}/bin/mv#g" \
        -e "s#/bin/ls#${coreutils}/bin/ls#g" \
        -e "s#/bin/cat#${coreutils}/bin/cat#g" \
        -e "s#/bin/sed#${gnused}/bin/sed#g" \
        -e "s#/bin/date#${coreutils}/bin/date#g" \
        -e "s#/usr/bin/dirname#${coreutils}/bin/dirname#g" \
        -e "s#/usr/bin/basename#${coreutils}/bin/basename#g" \
        -e "s#/usr/bin/realpath#${coreutils}/bin/realpath#g" \
        -e "s#/usr/bin/find#${findutils}/bin/find#g" \
        "$f"
    done

    ${gnused}/bin/sed -i -E \
      -e 's/^([[:space:]]*)ret = subprocess\.call\(\["systemctl", "start", "mssql-server"\]\)$/\1ret = 0/' \
      -e 's/^([[:space:]]*)ret = subprocess\.call\(\["systemctl", "enable", "mssql-server"\]\)$/\1ret = 0/' \
      -e 's#\["bash", "-l", pathToScript\]#["${bash}/bin/bash", pathToScript]#' \
      $out/opt/mssql/lib/mssql-conf/mssqlconfhelper.py

    if ${gnugrep}/bin/grep -q 'subprocess.call(\["systemctl", "start", "mssql-server"\])' \
      $out/opt/mssql/lib/mssql-conf/mssqlconfhelper.py; then
      echo "failed to patch mssqlconfhelper.py systemctl start call" >&2
      exit 1
    fi
    if ${gnugrep}/bin/grep -q 'subprocess.call(\["systemctl", "enable", "mssql-server"\])' \
      $out/opt/mssql/lib/mssql-conf/mssqlconfhelper.py; then
      echo "failed to patch mssqlconfhelper.py systemctl enable call" >&2
      exit 1
    fi
    if ${gnugrep}/bin/grep -q '\["bash", "-l", pathToScript\]' \
      $out/opt/mssql/lib/mssql-conf/mssqlconfhelper.py; then
      echo "failed to patch mssqlconfhelper.py login shell invocation" >&2
      exit 1
    fi

    cat > $out/opt/mssql/lib/mssql-conf/checkrunninginstance.sh <<EOF
    #!${bash}/bin/bash
    exec ${procps}/bin/pgrep -x sqlservr >/dev/null 2>&1
    EOF
    chmod 755 $out/opt/mssql/lib/mssql-conf/checkrunninginstance.sh

    patchShebangs $out/opt/mssql/bin $out/opt/mssql/lib/mssql-conf

    runHook postInstall
  '';

  meta = {
    description = "Microsoft SQL Server 2025 database engine";
    homepage = "https://www.microsoft.com/en-us/sql-server";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
  };
}
