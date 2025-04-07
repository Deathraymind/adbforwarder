let
  pkgs = import <nixpkgs> {};
in
pkgs.callPackage ./adbforwarder.nix {}
