#!/bin/bash
# Drush-Bash tricks 0.1
# Copyright 2010, 2013 Nuvole; portions copyright 2013 Martin Møller.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# For a quick start: copy this entire file to the end of the .bashrc
# file in your home directory and it will be enabled at your next
# login. See http://nuvole.org/node/26 for more details and options.

# Drupal and Drush aliases.
# To be added at the end of .bashrc.
alias drsp='cp sites/default/default.settings.php sites/default/settings.php'
alias drcc='drush cache-clear all'
alias drdb='drush updb && drush cc all'
alias drdu='drush sql-dump --ordered-dump --result-file=dump.sql'
alias dren='drush pm-enable -y'
alias drdis='drush pm-disable -y'
alias drun='drush pm-uninstall'
alias drf='drush features'
alias drfd='drush features-diff'
alias drfu='drush -y features-update'
alias drfr='drush -y features-revert'
alias drfra='drush -y features-revert all'
alias dr='drush'
alias dml='modlist'

# Completion. For personal use, just copy all the code below to
# the end of .bashrc; for system-wide use, copy to a file like
# /etc/bash_completion.d/drush_custom instead.

_drupal_root() {
  # Go up until we find index.php
  current_dir=`pwd`;
  while [ ${current_dir} != "/" -a -d "${current_dir}" -a \
          ! -f "${current_dir}/index.php" ] ;
  do
    current_dir=$(dirname "${current_dir}") ;
  done
  if [ "$current_dir" == "/" ] ; then
    exit 1 ;
  else
    echo "$current_dir" ;
  fi
}

_drupal_modules_in_dir()
{
  COMPREPLY=( $( compgen -W '$( command find $1 -regex ".*\.module" -exec basename {} .module \; 2> /dev/null )' -- $cur  ) )
}

_drupal_modules()
{
  local cur
  COMPREPLY=()
  cur=${COMP_WORDS[COMP_CWORD]}
  local drupal_root=`_drupal_root` && \
  _drupal_modules_in_dir "$drupal_root/sites $drupal_root/profiles $drupal_root/modules"
}

_drupal_features_in_dir()
{
  COMPREPLY=( $( compgen -W '$( command find $1 -regex ".*\.features.inc" -exec basename {} .features.inc \; 2> /dev/null )' -- $cur  ) )
}

_drupal_features()
{
  local cur
  COMPREPLY=()
  cur=${COMP_WORDS[COMP_CWORD]}
  local drupal_root=`_drupal_root` && \
  _drupal_features_in_dir "$drupal_root/sites $drupal_root/profiles $drupal_root/modules"
}

cdd()
{
  local drupal_root=`_drupal_root` && \
  if [ "$1" == "" ] ; then
    cd "$drupal_root";
  elif [[ "$1" == @* ]] ; then
    echo "Taking you to the $1 site alias...";
    pushd `drush dd $1`;
  else
    cd `find $drupal_root -regex ".*/$1\.module" -exec dirname {} \;`
  fi
}

modlist(){
 if [ "$1" == "" ] ; then
    drush pm-list
 elif [ "$1" == "--help" ] ; then
    echo "Uage: modlist [searchterm] Where searchterm is what will be grep'ed for."
    echo ""
    echo "modlist withut any paramter will give a list of all modules in the current drupal installation"
    echo ""
    echo "example: modlist core - will give be equal drush pm-list | grep core"
 else
    drush pm-list | grep $1
 fi
}

drinst(){
  if [ "$1" == "" ] ; then
    echo "At least one argument should be given."
    echo "Usage: drinst [module_name] -- example: drinst examples"
  else
    drush dl $1 -y
    drush en $1 -y
  fi
}

dalias(){
  echo "Different custom actions for drush"
  echo ""
  echo "Commands:"
  echo "  cdd -- Goes to the root of the current Drupal installation"
  echo "  drdb -- A combination of drush updb and drush cc all. First updates will be run and then cache will be cleared."
  echo "  modlist (dml) -- Prints a list of modules found in the current Drupal installation. A grep parameter can be added to grep for specific terms. E.g.: 'modlist user'. Use 'modlist help' for help"
  echo ""
  echo "  drinst -- Installs and enables the specified module. A modulename should be provided as argument 1 -- example: drinst examples"
  echo "  dren -- Enables the specified module. A modulename should be provided as argument 1 -- example: dren examples"
  echo "  drdis -- Disables the specified module. A modulename should be provided as argument 1 -- example: drdis examples"
  echo ""
}

complete -F _drupal_modules dren
complete -F _drupal_modules drdis
complete -F _drupal_modules drun
complete -F _drupal_features drfr
complete -F _drupal_features drfu
complete -F _drupal_features drfd
complete -F _drupal_modules cdd
complete -F _drupal_modules modlist
