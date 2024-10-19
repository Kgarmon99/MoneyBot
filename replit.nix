{ pkgs }: {
  deps = [
    pkgs.haskellPackages.concurrent-dns-cache
    pkgs.awscli
    pkgs.nodePackages.vscode-langservers-extracted
    pkgs.nodePackages.typescript-language-server  
  ];
}