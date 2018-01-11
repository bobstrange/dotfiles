alias apm-installed="apm list -bi"
apm-install() { apm install $@; apm-installed > ~/dotfiles/atom/installed_packages }
alias apm-bundle="apm install --packages-file ~/dotfiles/atom/installed_packages"
