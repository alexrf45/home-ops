# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:
let 
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz";
in 

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];
 nix.settings.experimental-features = [ "nix-command" "flakes" ];
 home-manager.useUserPackages = true;
 home-manager.useGlobalPkgs = true;
 home-manager.backupFileExtension = "backup";
 home-manager.users.sean = import ./home.nix;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-fr3d"; # Define your hostname.
#  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  services.xserver = {
    enable = true;
    windowManager.i3.enable = true;
    #windowManager.i3.terminal = "alacritty";
    #windowManager.qtile.enable = true;  
    displayManager.sessionCommands = ''
      xwallpaper --zoom ~/.config/pictures/nix.png
      xset r rate 200 35 &
    '';
  };

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable sound.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  
  services.pipewire = {
    enable = true; # if not already enabled
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    socketActivation = true;
    wireplumber.enable = true;
  };
  services.tailscale.enable = true;
  services.syncthing.enable = true;
  # Define a user account. Don't forget to set a password with ‘passwd’.
 users.users.sean = {
   isNormalUser = true;
   extraGroups = [ "wheel"  "networkmanager" "audio"]; 
   packages = with pkgs; [
     tree
   ];
 };
 
programs.firefox.enable = false;

#virtualisation.vmware.guest.enable = true;

 environment.systemPackages = with pkgs; [
   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
   wget
   neovim
   alacritty
   btop
   xwallpaper
   git
   rofi
   pfetch
   pcmanfm
   kubectl
   kubectl-ktop
   kubectl-cnpg
   kubectl-example
   kubectl-node-shell
   kubecolor
   kubectx
   terraform
   terraform-ls
   terraform-docs
   fluxctl
   fluxcd
   python313
   go
   wget
   curl
   aria2
   age
   aws-vault
   tmux
   tmuxp
   brave
   obsidian
   lxappearance
   open-vm-tools
   zsh
   starship
   gnumake
   pavucontrol
   noto-fonts-color-emoji
   gcc
   unzip
   nodejs_23
 ];
 environment.variables.EDITOR = "nvim";

   fonts.packages = with pkgs; [
             jetbrains-mono
             fira-code
             noto-fonts
             noto-fonts-cjk-sans
             noto-fonts-emoji
             liberation_ttf
             fira-code-symbols
             fira-code-nerdfont
             mplus-outline-fonts.githubRelease
             dina-font
             proggyfonts
];

 

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
   programs._1password = { enable = true; };

   programs._1password-gui = {
     enable = true;
     # this makes system auth etc. work properly
    polkitPolicyOwners = [ "sean" ];
   };
   programs.gnupg.agent = {
     enable = true;
     enableSSHSupport = true;
   };
   nixpkgs.config.allowUnfree = true;
  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  system.stateVersion = "24.11"; # Did you read the comment?

}

