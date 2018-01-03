#!/bin/bash

# Install ruby
for version in 2.3.1 2.3.3 2.5.0; do
  echo "Installing ruby ${version}"
  rbenv install ${version}
  echo "Finished install ruby ${version}"
  echo "Installing bundler for ruby ${version}"
  rbenv global ${version}
  gem install bundler
  echo "Finished to install bundler for ruby ${version}"
done

## Set ruby global version as 2.5.0 for now
rbenv global 2.5.0

# Install node
for version in v6.9.2 v6.12.3; do
  echo "Installing node ${version}"
  ndenv install ${version}
  echo "Finished install node ${version}"
done

## Set node global version as 6.12.3 for now
ndenv global v6.12.3

## Setup yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install yarn -y
