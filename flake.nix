{
  description = "Personal Infrastructure";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; # Add unstable as main cache
    futils.url = "github:numtide/flake-utils"; # Add flake utils
    # Let's add a pre-commit-hook that will allow us to do some
    # simple formating checks on the code
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        nixpkgs-stable.follows = "nixpkgs";
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "futils";
      };
    };
  };

  outputs = { self, nixpkgs, futils, pre-commit-hooks } @ inputs:
    let
      inherit (nixpkgs) lib;
      inherit (futils.lib) eachDefaultSystem;

      pkgImport = pkgs: system:
        import pkgs {
          inherit system;
          config.allowUnfree = true;
        };
    in
    eachDefaultSystem (system:
      let
        pkgs = pkgImport nixpkgs system;
        hook = pre-commit-hooks.lib.${system};
        tools = import "${pre-commit-hooks}/nix/call-tools.nix" pkgs;
      in
      rec {
        checks.pre-commit-check = hook.run {
          src = self;

          tools = tools;
          # Here we define the pre-hooks that we want
          hooks = {
            nixpkgs-fmt.enable = true;
            markdownlint.enable = true; # In case i do some markdown
            terraform-format.enable = true;
            yamllint.enable = true;
            ansible-lint.enable = true;
          };
        };

        devShell = pkgs.mkShell {
          name = "Shaadx_Infra";

          shellHook = "${checks.pre-commit-check.shellHook}";

          buildInputs = with pkgs; [
            terraform
            git
          ];

          packages = with pkgs; [
            rnix-lsp

            tools.terraform-fmt
            tools.ansible-lint
            tools.nixpkgs-fmt
            tools.markdownlint-cli
          ];
        };
      }
    );
}
