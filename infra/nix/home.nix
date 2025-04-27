{ config, pkgs, ... }:

{ 
  home.username = "sean";
  home.homeDirectory = "/home/sean";
  home.stateVersion = "24.11";
  
  programs.bash = { 
    enable = true;
    shellAliases = {
      c = "clear";
      nrs = "sudo nixos-rebuild switch";
      q = "exit";
      r = ". ~/.bashrc";
      d = "docker";
      t = "tmux";
      f = "flux";
      k = "kubectl";
      v = "nvim";
      kgn = "kubectl get nodes";
      kg = "kubectl get";
      kaf = "kubectl apply -f";
      kgd = "kubectl get deployment";
      tf = "terraform";
      tfo = "terraform output";
      tfir = "terraform init -backend-config='remote.tfbackend' -upgrade";
  
    };
    initExtra = ''
     PS1='\[\e[38;5;195;1m\]\w\[\e[0m\] \$ '
     source "/home/sean/.config/op/plugins.sh"
    '';
    bashrcExtra = ''
       encrypt_age() {
         age \
         --passphrase \
         --output $1.enc \  
         $2
        }

	decrypt_age() {
	  age -d \
	    $1 >$2
	}
    '';
   };
   programs.alacritty = {
     enable = true;
     settings = {
       font.normal = {
         family = "JetBrains Mono";
         style = "Regular";
       };
       font.size = 13;
       window.dynamic_padding = true;
       window.decorations = "None";
       cursor.style = "underline";
       selection.save_to_clipboard = true;
       terminal.shell = {
          program = "/etc/profiles/per-user/sean/bin/bash";
       };
      };
   }; 
   home.file.".config/bat/config".text = ''
     --theme="Nord"
     --style="numbers,changes,grid"
     --paging=auto
   '';

   home.packages = with pkgs; [
   awscli2
   bat
   jq
   docker
   fzf
   ncspot
   ];
}
