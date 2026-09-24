{ buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "pgtui";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "pgplex";
    repo = "pgtui";
    rev = "v${version}";
    hash = "sha256-qGWKsjF5lYWxtXHWib2QK/LtNW7RAEnlmRGZREW2wKg=";
  };

  vendorHash = "sha256-jdwl+ganflen4vG1JjpazkxrRzT7eGWYj6UHmiwlono=";

  meta = {
    description = "Terminal UI for PostgreSQL, written in Go with Bubble Tea";
    homepage = "https://github.com/pgplex/pgtui";
  };
}
