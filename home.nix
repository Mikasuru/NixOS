{ pkgs, ... }: {
  home.stateVersion = "25.05";

  # --- Git Configuration ---
  programs.git = {
    enable = true;
    userName = "---------";
    userEmail = "-----------";
  };

  # Shell: Bash with Lain-inspired ---
  programs.bash = {
    enable = true;
    shellAliases = {
      # System & Navigation
      ll = "ls -alF"; la = "ls -A"; l = "ls -CF";
      ".." = "cd .."; "..." = "cd ../.."; "...." = "cd ../../..";
      grep = "grep --color=auto";
      
      # Git
      gs = "git status"; ga = "git add"; gc = "git commit";
      gp = "git push"; gl = "git log --oneline"; gd = "git diff";
      
      # NixOS
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#lain";
      reconfig = "sudo nano /etc/nixos/flake.nix";
      
      # Development
      py = "python3"; pip = "python3 -m pip";
      
      # Hardware
      gpu = "nvidia-smi"; gpuwatch = "nvidia-smi -l 1";
      perf = "asusctl profile -P Performance";
      balanced = "asusctl profile -P Balanced";
      quiet = "asusctl profile -P Quiet";
      
      # Utilities
      weather = "curl wttr.in/Hat+Yai"; myip = "curl ipinfo.io/ip";
      
      # Lain-inspired
      connect = "nmtui"; # "Let's all love Lain"
      wired = "ip addr show"; # Check network "wired" status
      present = "date"; # "Present day, present time"
    };
    initExtra = ''
      # ===== Navi / fastfetch-like boot panel =====
      if [ -z "$LAIN_BOOT_SILENT" ] && [ -t 1 ]; then
        _d(){ [ "''${LAIN_FAST:-0}" = "1" ] || sleep "$1"; }
        esc(){ printf '\033[%sm' "$1"; }
        B=$(esc 1); D=$(esc 2); K=$(esc 90); W=$(esc 97); R=$(esc 31); C=$(esc 36); G=$(esc 32); Y=$(esc 33); O=$(esc 0)
        _val(){ printf "%s" "''${1:-unknown}"; }
        _user="''${USER:-user}"
        _host="$(hostname 2>/dev/null || echo navi)"
        _os="$(if [ -f /etc/os-release ]; then . /etc/os-release 2>/dev/null; echo "''${PRETTY_NAME:-$NAME}"; elif command -v uname >/dev/null 2>&1; then echo "$(uname -s)"; else echo "Linux"; fi)"
        _kern="$(uname -sr 2>/dev/null || echo Linux)"
        _shell="$SHELL"
        _term="$TERM"
        _de="''${XDG_CURRENT_DESKTOP:-''${XDG_SESSION_DESKTOP:-tty}}"
        _cpu="$(if command -v lscpu >/dev/null 2>&1; then lscpu | awk -F: '/Model name/{gsub(/^ +/,"",$2);print $2;exit}'; elif [ -r /proc/cpuinfo ]; then awk -F: '/model name/{print $2; exit}' /proc/cpuinfo | sed 's/^ //'; fi)"
        _gpu="$(if command -v nvidia-smi >/dev/null 2>&1; then nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1; elif command -v lspci >/dev/null 2>&1; then lspci | grep -iE 'vga|3d|display' | head -1 | sed 's/^[^:]*: //'; fi)"
        _mem="$(if [ -r /proc/meminfo ]; then awk '/MemTotal:/ {tot=$2} /MemAvailable:/ {free=$2} END{used=(tot-free)/1024/1024; tot=tot/1024/1024; printf("%.1fGiB / %.1fGiB", used, tot)}' /proc/meminfo; fi)"
        printf "\033[2J\033[H"
        _logo="$(cat <<'__NAVI_ASCII__' 
                       ███                
                       ███                
                                          
               ██   █████████   ██        
            █████ █████████████ █████     
          █████  ████       ████   ████   
          ███   ████  █████  ████   ████  
          ███   ████ ███████ ████   ████  
           ████  ███  █████  ███  ████    
             ████ ████     ████ ████      
          ██   ██  █████ █████  ██   ██   
          ████       ███ ███       ████   
                     ███ ███              
                ███  ███ ███  ███         
                ████████ ████████         
                  ████     ████           
__NAVI_ASCII__
)"
        _rows=(
            "User    : $_user@$_host"
            "OS      : $_os"
            "Kernel  : $_kern"
            "Shell   : $_shell"
            "DE      : $_de"
            "CPU     : ''${_cpu:-unknown}"
            "GPU     : ''${_gpu:-unknown}"
            "Memory  : ''${_mem:-unknown}"
          )
        printf "%s⟦ wired interface ⟧──────────────────────────────────%s\n" "$K" "$O"
        logo_lines="$(printf '%s\n' "$_logo" | wc -l)"
        max_lines=$(( logo_lines > ''\${#_rows[@]} ? logo_lines : ''\${#_rows[@]} ))
        i=0
        while [ $i -lt $max_lines ]; do
            left_line="$(printf '%s\n' "$_logo" | sed -n "$((i+1))p")"
            right_line="''\${_rows[i]}"
            printf "%s%-*s%s%s%s\n" "$W" 22 "''\${left_line:- }" "$O" "   " "''\${right_line:-}"
            _d 0.005
            i=$((i+1))
        done
        printf "%s────────────────────────────────────────────────────%s\n" "$K" "$O"
        printf "%sλ%s Welcome to the %sWired%s, %s%s%s.\n" "$R" "$O" "$W" "$O" "$B" "$_user" "$O"
        unset -f esc _d _val
        unset B D K W R C G Y O _user _host _os _kern _shell _term _de _cpu _gpu _mem _logo _rows logo_lines max_lines i
      fi
    '';
  };

  # --- Shell Prompt: Starship ---
  programs.starship = {
    enable = true;
    settings = {
      format = "[⟦](dimmed white)[$username](bold bright-black)@[$hostname](bold bright-black)[⟧](dimmed white) [$directory](bold bright-white)$git_branch$git_status$line_break[λ](bold red) ";
      add_newline = false;
      character = { success_symbol = "[λ](bold white)"; error_symbol = "[λ](bold red)"; };
      directory.substitutions = {
        "Documents" = "D"; "Downloads" = "DL"; "Music" = "M"; "Pictures" = "P";
        "Videos" = "V"; "Projects" = "PRJ"; "Code" = "SRC"; "/home/lain" = "lain/";
      };
      # Other starship settings...
    };
  };

  # --- VS Code Configuration ---
  programs.vscode = {
    enable = true;
    profiles.default.userSettings = {
      "workbench.colorTheme" = "Default Dark Modern";
      "editor.fontFamily" = "'JetBrains Mono', 'Hack', monospace";
      "editor.fontSize" = 14;
      "editor.fontLigatures" = true;
      "terminal.integrated.fontSize" = 13;
      "workbench.startupEditor" = "none";
      "editor.minimap.enabled" = false;
      "workbench.activityBar.location" = "top";
    };
  };

  # --- Gnome & GTK Theme (Lain Aesthetic) ---
  dconf.settings = {
    # Enabled Extensions
    "org/gnome/shell" = {
      enabled-extensions = [
        "blur-my-shell@aunetx"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "dash-to-dock@micxgx.gmail.com"
        "Vitals@CoreCoding.com"
      ];
    };
    
    # Dark Theme and Fonts
    "org/gnome/desktop/interface" = {
      gtk-theme = "Adwaita-dark";
      icon-theme = "Adwaita";
      text-scaling-factor = 1.25;
      clock-show-seconds = true;
    };
    "org/gnome/desktop/wm/preferences".theme = "Adwaita-dark";

    # Terminal Profile (Matrix Green)
    "org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = {
      visible-name = "Lain";
      background-color = "rgb(0,0,0)";
      foreground-color = "rgb(0,255,41)";
      use-theme-colors = false;
      use-transparent-background = true;
      background-transparency-percent = 10;
    };

    # Extension Settings
    "org/gnome/shell/extensions/blur-my-shell/panel" = { blur = true; brightness = 0.8; sigma = 15; };
    "org/gnome/shell/extensions/blur-my-shell/overview" = { blur = true; brightness = 0.8; sigma = 15; };
    "org/gnome/shell/extensions/dash-to-dock" = { dock-position = "BOTTOM"; transparency-mode = "DYNAMIC"; };
    "org/gnome/shell/extensions/vitals" = { show-gpu = true; show-memory = true; show-processor = true; show-network = true; };
  };

  # --- Custom Desktop Entry for Brave with Nvidia offload ---
  xdg.desktopEntries.brave-nvidia = {
    name = "Brave Browser (Nvidia)";
    comment = "Web browser with Nvidia GPU";
    exec = "env __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia brave %U";
    icon = "brave-browser";
    terminal = false;
    type = "Application";
    categories = [ "Network" "WebBrowser" ];
  };
}
