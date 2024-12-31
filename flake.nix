{
  description = "@builder.io/ai-shell";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Use an absolute or relative path (no '~') for local flakes
    #snow-blower.url = "path:/home/hobbes/Documents/snow-blower";
    #snow-blower.url = "path:/home/hobbes/Documents/snow-blower";

    snow-blower.url = "github:peoplenamed/snow-blower";

    dream2nix.url = "github:nix-community/dream2nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ { flake-parts, dream2nix, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # Optional: Additional modules from `snow-blower`
      imports = [
        inputs.snow-blower.flakeModule
      ];

      # The set of systems this flake will handle
      systems = nixpkgs.lib.systems.flakeExposed;

      # 1) Define your system-specific configuration
      perSystem = { pkgs, system, ... }:
      let
        # Evaluate the ai-shell using dream2nix
        aiShell = dream2nix.lib.evalModules {
          packageSets.nixpkgs = dream2nix.inputs.nixpkgs.legacyPackages.${system};
          modules = [
            ./default.nix
            {
              paths.projectRoot = ./.;
              paths.projectRootFile = "flake.nix";
              paths.package = ./.;
            }
          ];
        };
      in
      {
        packages = {
          # The main AI Shell package for this system
          ai-shell = aiShell;

          # Optional: define a `default` alias to ai-shell
          # so you can build with `nix build .#packages.x86_64-linux.default`
          default = aiShell;
        };

        # If you want to define Home Manager configurations here, you can:
        # homeConfigurations = {
        #   hobbes = home-manager.lib.homeManagerConfiguration {
        #     pkgs = pkgs;
        #     modules = [
        #       {
        #         home.packages = [ aiShell ];
        #       }
        #     ];
        #   };
        # };
      };
    };
}
