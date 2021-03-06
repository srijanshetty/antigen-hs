# See https://github.com/Tarrasch/antigen-hs
if [[ "$0" != $HOME/.zsh/antigen-hs/init.zsh ]]
then
  echo "Put this file in '~/.zsh/antigen-hs/init.zsh' please!"
fi

() {
  local FILE_TO_SOURCE="$HOME/.antigen-hs/antigen-hs.zsh"
  if [[ -f $FILE_TO_SOURCE ]]
  then
    source $FILE_TO_SOURCE
  else
    echo "Didn't find file $FILE_TO_SOURCE"
    echo "Try running antigen-hs-compile"
  fi
}

antigen-create() {
    # Get the list of bundles
    [ -e $HOME/.zsh/bundles ] || touch $HOME/.zsh/bundles
    list=("${(f)$(< $HOME/.zsh/bundles)}")
    BUNDLES=$(IFS=','; echo "${list[*]}"; IFS=$' \t\n')


    [ -e $HOME/.antigen-hs ] || mkdir $HOME/.antigen-hs
    [ -e $HOME/.antigen-hs/MyAntigen.hs ] && rm -f $HOME/.antigen-hs/MyAntigen.hs

    HEADER='
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExtendedDefaultRules #-}
module MyAntigen where

import Antigen (AntigenConfiguration (..), bundle, antigen)
import Shelly (shelly)

bundles = [
'

    FOOTER=']

config = AntigenConfiguration bundles

main :: IO ()
main = shelly $ antigen config
'
    echo "$HEADER $BUNDLES $FOOTER" > $HOME/.antigen-hs/MyAntigen.hs
}

antigen-hs-compile () {
    antigen-create
    runghc -i"$HOME/.zsh/antigen-hs/" -- "$HOME/.antigen-hs/MyAntigen.hs"
}

antigen-update() {
    CURRENT_DIR=$PWD
    for folder in $(find $HOME/.antigen-hs/repos/ -maxdepth 1 -mindepth 1 -type d); do
        echo "\nIn folder $folder"
        cd $folder && git pull origin master
    done
    cd $CURRENT_DIR
}

antigen-list() {
    list=("${(f)$(< $HOME/.zsh/bundles)}")

    length=${#list[*]}
    for ((i=1; i<=length; i=i+1)); do
        echo "$i : $list[i]"
    done
}

antigen-add() {
    echo "bundle \"$1\"" >> $HOME/.zsh/bundles
    antigen-hs-compile
}

antigen-remove() {
    list=("${(f)$(< $HOME/.zsh/bundles)}")
    list[$1]=()

    set +C
    [ -e $HOME/.zsh/bundles ] && : > $HOME/.zsh/bundles
    IFS=$'\n'; echo "${list[*]}" > $HOME/.zsh/bundles; IFS=$' \t\n'
    set -C
}
