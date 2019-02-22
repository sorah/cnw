#!/bin/bash -xe
if [ ! -e ../cnw/itamae ]; then
  echo "Add submodule to ../cnw then run again" 1>&2
  exit 1
fi
ln -s ../cnw/itamae cnw
ln -s ../cnw/itamae/site.rb site.rb
cp ../cnw/itamae/vars.rb vars.rb
cp ../cnw/itamae/hocho.yml hocho.yml
cp ../cnw/itamae/Gemfile Gemfile
echo '/secrets/keys/' >> .gitignore
