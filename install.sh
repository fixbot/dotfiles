#! /bin/bash
####################################
#Install for all configs in Arch
####################################

####FUNCTIONS####

#arch pianobar-git install
archPB() {
  mkdir $HOME/pb_build && cd $HOME/pb_build
  curl -L https://aur.archlinux.org/packages/pi/pianobar-git/pianobar-git.tar.gz > pianobar-git.tar.gz
  tar -xf pianobar-git.tar.gz
  cd pianobar-git
  makepkg -si
  cd $HOME
  rm -rf $HOME/pb_build
  echo -e "Pianobar installed... \n"
}

archPianobar() {
  sudo mv /etc/libao.conf /etc/liba.conf.bak
  sudo echo "default_driver=pulse" > /etc/libao.conf
}

#arch python2-powerline-git install
archPowerline() {
  mkdir $HOME/pl_build && cd $HOME/pl_build
  curl -L https://aur.archlinux.org/packages/py/python2-powerline-git/python2-powerline-git.tar.gz > python2-powerline-git.tar.gz
  tar -xf python2-powerline-git.tar.gz 
  cd python2-powerline-git
  makepkg -si
  cd $HOME
  rm -rf $HOME/pl_build
}
  
#Install oh-my-zsh
ohmyzsh() {
  echo -e "Installing oh-my-zsh...\n"
  curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh
  #in case prompt fails for zsh
  chsh -s /bin/zsh
}

#git and clone the git file for install
cloneRepo() {
  echo -e "Cloning dotfile repo into directory...\n"
  git clone https://github.com/FreekingDean/dotfiles.git $HOME/.dotfiles
}

####END FUNCTIONS####

echo -e "PREPARE YOUR ARCH FOR SOME MOFUCKIN DOTS."

echo -e "Updating then installing zsh wget curl git gvim & tmux...\n"
sudo pacman -Syu
sudo pacman -S zsh git curl wget gvim tmux

#clone the repo into users home dir
cloneRepo

#install oh-my-zsh
ohmyzsh

#Install vimrc zshrc and functions
echo -e "Symlinking vimrc, zshrc, tmux.conf and such to HOME...\n"
mv $HOME/.zshrc $HOME/.zshrc.bak #remove original zshrc

ln -s $HOME/.dotfiles/zshrc $HOME/.zshrc
ln -s $HOME/.dotfiles/tmux.conf $HOME/.tmux.conf
ln -s $HOME/.dotfiles/zsh_aliases $HOME/.zsh_aliases
ln -s $HOME/.dotfiles/vimrc $HOME/.vimrc
ln -s $HOME/.dotfiles/tmux $HOME/.tmux
ln -s $HOME/.dotfiles/Xresources $HOME/.Xresources
ln -s $HOME/.dotfiles/irssi $HOME/.irssi

mkdir -p $HOME/.vim/tmp $HOME/.vim/backups

echo -e "Running basic git configuration...\n"
read -p "Enter your name (full name): " name
read -p "Enter your git email address: " email
git config --global user.name $name
git config --global user.email $email

#install pianobar and save configurationG
echo -e "Installing pianobar...\n"
archPB
archPianobar

echo -e "Creating pianobar config...\n"
read -p "Enter your pandora email address: " pandMail
read -s -p "Enter your pandora password: " pandPass
mkdir -p $HOME/.config/pianobar/ && touch $HOME/.config/pianobar/config
echo "" > $HOME/.config/pianobar/config
echo "user = $pandMail" >> $HOME/.config/pianobar/config
echo "password = $pandPass" >> $HOME/.config/pianobar/config

#Vundle installation and plugin install from vimrc
echo -e "Installing Vundle and running BundleInstall for vim plugins...\n"
git clone https://github.com/gmarik/vundle.git $HOME/.vim/bundle/vundle
vim +BundleInstall +qall

ehco -e "Installing powerline...\n"
archPowerline