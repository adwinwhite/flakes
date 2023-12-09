{ lib, rustPlatform }:

rustPlatform.buildRustPackage {
  pname = "static-host";
  version = "0.0.1";

  src = builtins.fetchGit {
    url = "git@github.com:adwinwhite/static.git";
    rev = "d2dec8dc46c7eb58497f749d9ea170eee42a46b8";
  };

  cargoHash = "sha256-syURRrNrIaEF9735w6eu9XYE/+ovfTHplhapQdVZXuY=";

  meta = with lib; {
    description = "A pastebin for static files";
    homepage = "https://github.com/adwinwhite/static";
    license = licenses.unlicense;
    maintainers = [];
  };
}
