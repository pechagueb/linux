# Agregar a .bash_aliases
# Ej.: cat ~/bash_aliases >> ~/.bash_aliases
#      o copiar contenido
#
# Agregados de Patricio Echagüe Ballesteros
 
export EDITOR='nano'

alias update='sudo apt update && \
	      sudo apt upgrade -y && \
	      sudo apt dist-upgrade -y && \
	      sudo flatpak update && \
	      sudo apt clean && \
	      sudo apt autoclean && \
	      sudo apt autoremove -y'

alias tg='topgrade -y'
alias ff='fastfetch'
alias trim='sudo fstrim / -v'
alias bashed='sudo nano ~/.bashrc'
alias off='echodbus-send --session --print-reply --dest=org.kde.kglobalaccel  /component/org_kde_powerdevil org.kde.kglobalaccel.Component.invokeShortcut string:"Turn Off Screen"'

#Yazi
function yz() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# theFuck
eval $(thefuck --alias)

# HomeBrew
# echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Para compatibilidad con flutter
export CHROME_EXECUTABLE=/var/lib/flatpak/exports/bin/com.google.Chrome

#Autocompletado predictivo estilo Zsh
source ~/ble.sh/out/ble.sh

ff
echo
~/quotes.sh ~/quotes.txt
echo
~/oncehoy.sh
