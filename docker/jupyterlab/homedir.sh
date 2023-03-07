#!/bin/sh

# Copy .bashrc and .bash_profile if it doesn't already exist in the users home directory

if [ ! -d "$HOME"];
then
    mkdir -p $HOME
    chmod $NB_UID $HOME
fi

if [ ! -f "$HOME/.bashrc" ]; then
  cp /ssb/share/etc/skel/.bashrc "$HOME/.bashrc"
  chown $NB_UID "$HOME/.bashrc"
fi

if [ ! -f "$HOME/.bash_profile" ]; then
  cp /ssb/share/etc/skel/.bash_profile "$HOME/.bash_profile"
  chown $NB_UID "$HOME/.bash_profile"
fi
