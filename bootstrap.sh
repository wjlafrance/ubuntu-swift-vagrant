sudo apt-get update
sudo apt-get dist-upgrade -y
sudo apt-get install -y clang libicu-dev apache2

mkdir -p /vagrant/data

if [ ! -f /vagrant/data/swift-2.2-RELEASE-ubuntu15.10.tar.gz ]; then
	wget -q https://swift.org/builds/swift-2.2-release/ubuntu1510/swift-2.2-RELEASE/swift-2.2-RELEASE-ubuntu15.10.tar.gz \
		-O /vagrant/data/swift-2.2-RELEASE-ubuntu15.10.tar.gz
fi
if [ ! -f /vagrant/data/swift-interp ]; then
	wget -q https://gist.github.com/wjlafrance/31df15769c9e385c15aa/raw/af26a36f041869e879aea14d48a37b870270b896/swift-interp \
		-O /vagrant/data/swift-interp
fi
if [ ! -f /vagrant/data/swift-compiled.swift ]; then
	wget -q https://gist.github.com/wjlafrance/31df15769c9e385c15aa/raw/af26a36f041869e879aea14d48a37b870270b896/swift-compiled.swift \
		-O /vagrant/data/swift-compiled.swift
fi

sudo sed -i "s/PermitRootLogin without-password/PermitRootLogin no/g" /etc/ssh/sshd_config
sudo sed -i "s/PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config
sudo service ssh restart

sudo a2enmod cgi
sudo service apache2 restart

if [ -d /opt/apple ]; then
	sudo rm -rf /opt/apple
fi
sudo mkdir -p /opt/apple
sudo tar -xzf /vagrant/data/swift-2.2-RELEASE-ubuntu15.10.tar.gz -C /opt/apple
sudo ln -s /opt/apple/swift-2.2-RELEASE-ubuntu15.10 /opt/apple/swift-current
sudo update-alternatives --install /usr/bin/swift swift /opt/apple/swift-current/usr/bin/swift 1
sudo update-alternatives --install /usr/bin/swiftc swiftc /opt/apple/swift-current/usr/bin/swiftc 1

sudo swiftc /vagrant/data/swift-compiled.swift -o /usr/lib/cgi-bin/swift-compiled
sudo cp /vagrant/data/swift-interp /usr/lib/cgi-bin
sudo chmod +x /usr/lib/cgi-bin/swift-interp
