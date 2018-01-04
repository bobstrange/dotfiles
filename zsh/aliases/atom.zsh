alias apm-installed="apm list -bi"
alias apm-install="apm install $1; apm-installed > ~/dotfiles/atom/installed_packages"
alias apm-bundle="apm install --packages-file ~/dotfiles/atom/installed_packages"
