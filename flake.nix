{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self, ... }@inputs:
    inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let

        # NOTE: Update this list with the Vim-plugins you want to use.
        vim-pkgs = with inputs; [
        ];
        # NOTE: Update this list with the Nix packages you want to use.
        native-pkgs = with pkgs; [
        ];

        pkgs = import inputs.nixpkgs { inherit system; };
        xdg-config-home = pkgs.stdenvNoCC.mkDerivation {
          name = "Virtual xdg-config-home";
          src = ./.;

          nativeBuildInputs = with pkgs; [
            rsync
          ];

          unpackPhase = ''
            runHook preUnpack

            mkdir -p out/nvim/pack/preInstalled/start
            cp -r ${builtins.concatStringsSep " " vim-pkgs} out/nvim/pack/preInstalled/start/

            rsync -av --exclude="out" ${./.}/* out/

            runHook postUnpack
          '';

          installPhase = ''
            runHook preInstall

            cp -r ./out $out

            runHook postInstall
          '';
        };

      in
      {
        devShells.default = pkgs.mkShell {
          env = {
            XDG_CONFIG_HOME = "${xdg-config-home}";
          };
          buildInputs =
            with pkgs;
            [
              neovim
            ]
            ++ native-pkgs;
          pure = true;
        };
      }
    );
}
