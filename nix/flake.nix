{
  description = "Configuration for development machines";

  inputs = {
      # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      nixpkgs.url = "github:NixOS/nixpkgs";  # Fetch the latest nixpkgs
  };

  outputs = { self, nixpkgs }:
  let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    devShells.${system}.default =
      pkgs.mkShell
        {
          buildInputs = [
            pkgs.neovim
            pkgs.nodejs
            pkgs.bat
            pkgs.eza
            pkgs.git
            pkgs.ripgrep
            pkgs.fzf
            pkgs.glibcLocales
            pkgs.lazygit
            pkgs.zsh
            pkgs.stow
            pkgs.starship
          ];

          shellHook = ''
            echo "Hi there from shellHook!"

            export LOCALE_ARCHIVE=${pkgs.glibcLocales}/lib/locale/locale-archive
            export LANG=en_US.UTF-8
            export LC_ALL=en_US.UTF-8

            if [ ! -d "$HOME/code/dotfiles" ]; then
                git clone https://github.com/leonidgrishenkov/dotfiles.git $HOME/code/dotfiles > /dev/null 2>&1
            fi

            stow -d $HOME/code/dotfiles --target=$HOME --stow nvim lazygit zsh bat starship --verbose

            export SHELL=$(which zsh)
            if [ -z "$ZSH_VERSION" ]; then exec zsh; fi
          '';
    };
  };
}
