{
  description = "Sai's NixOS config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs = inputs@{ nixpkgs, ... }: {
    nixosConfigurations.saislaptop = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [ ./configuration.nix ];
    };
  };
}
