# Agregar a bashrc
# Ej.: echo 'source ~/agregar-a-bashrc.pat' >> ~/.bashrc
#
#
 
export EDITOR='nano'

alias update='sudo apt update && \
	      sudo apt upgrade -y && \
	      sudo apt dist-upgrade -y && \
	      sudo flatpak update && \
	      sudo apt clean && \
	      sudo apt autoclean && \
	      sudo apt autoremove -y'

alias ff='fastfetch'
alias trim='sudo fstrim / -v'
alias bashed='sudo nano ~/.bashrc'
alias flush='sudo resolvectl flush-caches'
alias bios='sudo systemctl reboot --firmware-setup'
alias gpu='nvtop'

echo
ff
echo
~/quotes.sh ~/quotes.txt
echo
~/oncehoy.sh
echo
