{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  gtk3,
  withBold ? false,
}:

stdenvNoCC.mkDerivation {
  pname = "mactahoe-icon-theme";
  version = "839848b";

  # this package owns the whole theme, so keep the cache
  dontDropIconThemeCache = true;

  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = "MacTahoe-icon-theme";
    rev = "839848b9a8a38a92a6936e30c4abe35cc6f2546d";
    hash = "sha256-NAahlBOYub0QlqkYStamoCbyWh+H5JG/iFm4Ws9EU3A=";
  };

  nativeBuildInputs = [ gtk3 ];

  installPhase = ''
    runHook preInstall

    bash install.sh -d "$out/share/icons" -n MacTahoe ${lib.optionalString withBold "-b"}

    # remove unwanted inheritance
    for dir in "$out/share/icons"/*/; do
      sed -i 's/Inherits=.*/Inherits=/' "$dir/index.theme"
    done

    # update icon cache on all themes
    for dir in "$out/share/icons"/*/; do
      gtk-update-icon-cache "$dir"
    done

    runHook postInstall
  '';

  meta = {
    description = "MacOS Tahoe icon theme for Linux";
    homepage = "https://github.com/vinceliuice/MacTahoe-icon-theme";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
}
