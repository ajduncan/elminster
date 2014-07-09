#!/bin/sh

echo "
########################################################################
 _____ _           _           _            
| ____| |_ __ ___ (_)_ __  ___| |_ ___ _ __ 
|  _| | | '_ \ _ \| | '_ \/ __| __/ _ \ '__|
| |___| | | | | | | | | | \__ \ ||  __/ |   
|_____|_|_| |_| |_|_|_| |_|___/\__\___|_|   
                                            

########################################################################
"

if [ ! -e "/home/vagrant/provisioned" ]
then
	# Update and upgrade:
	echo "Updating system..."
	apt-get update > /dev/null 2>&1
	echo "Upgrading system packages..."
	apt-get -y upgrade > /dev/null 2>&1

	# Install system dependencies:
	echo "Installing system dependencies: haskell-platform, supervisor"
	apt-get -y install haskell-platform supervisor

	# Install cabal:
	su vagrant -c "cabal update"
	su vagrant -c "cabal install elm elm-server"

	# Add cabal to the path:
	su vagrant -c "echo \"export PATH=/home/vagrant/.cabal/bin:\$PATH\" >> ~/.bashrc"

	# Create supervisor config file:
	cat <<'EOF' > /etc/supervisor/conf.d/elminster.conf
	[program:elminster]
	command=/home/vagrant/.cabal/bin/elm-server
	directory=/vagrant/elminster
	user=vagrant
	environment=PATH=/home/vagrant/.cabal/bin/:%(ENV_PATH)s
EOF

	supervisorctl reload || exit 1

	touch /home/vagrant/provisioned
fi

echo
echo "Started elm server at http://localhost:8000/"
echo
