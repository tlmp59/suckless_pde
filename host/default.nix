{ inputs, lib, util, ... }@specialArgs: let
  inherit (inputs) nix-darwin home-manager;
  inherit (util) mylib myvar;

  genHosts = system: let
    sysHosts = mylib.dirsIn ./${system};

    sysAttrs = if lib.hasSuffix "darwin" system then {
      type = "darwin";
      func = nix-darwin.lib.darwinSystem;
      home = home-manager.darwinModules.home-manager;
    } else {
      type = "linux";
      func = lib.nixosSystem;
      home = home-manager.nixosModules.home-manager;
    };
  in with sysAttrs;
    lib.genAttrs sysHosts (
      hostname: func {
        inherit system specialArgs;
        modules = [
	  ./${system}/${hostname}/configuration.nix
	  ( mylib.relativeToRoot "module/${type}" )
        ];
      }
    );

in {
  nixosConfigurations = lib.mergeAttrsList
    ( map genHosts myvar.systems.linux);

  darwinConfigurations = lib.mergeAttrsList
    ( map genHosts myvar.systems.darwin);
}
