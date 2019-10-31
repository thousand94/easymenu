#!/bin/bash

PS3='wpisz cyfre wybranej opcji: '
options=("Openvpn serwer centos7" "Openvpn serwer debian9" "Openvpn klient centos7" "Openvpn klient Debian" "Routing podstawowy openvpn (na swiat)" "routing zawansowany (na swiat)" "LXC PROXMOX DEB9" "PROXMOX KVM" "CENTOS WEB PANEL" "CPANEL" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Openvpn serwer centos7")
            yum install nano wget -y
            sudo yum update -y
			ip a
			ip a show eth0
			cd /home
			mkdir root
			wget https://raw.githubusercontent.com/thousand94/easymenu/master/centos7vpnserver.sh
			chmod +x centos7-vpn.sh
			sudo ./centos7-vpn.sh
			iptables-save > /etc/firewall.conf
			echo "#!/bin/sh
			iptables-restore < /etc/firewall.conf" >> /sbin/ifup-local
			chmod +x /sbin/ifup-local
			;;
      	"Openvpn serwer debian9")
			sudo apt-get update -y
			sudo apt-get upgrade -y
			#sudo apt-get install ufw
			#sudo ufw allow 22
			#sudo ufw allow 80
			#sudo ufw allow 443
			#sudo ufw enable
			#sudo ufw status
			wget https://raw.githubusercontent.com/thousand94/easymenu/master/openvpnserverdeb9.sh
			sudo bash openvpnserverdeb9.sh
			cat /etc/rc.local
			sudo more /etc/openvpn/server.conf
			echo "port 1194
			proto udp
			dev tun
			sndbuf 0
			rcvbuf 0
			ca ca.crt
			cert server.crt
			key server.key
			dh dh.pem
			auth SHA512
			tls-auth ta.key 0
			topology subnet
			server 10.8.0.0 255.255.255.0
			ifconfig-pool-persist ipp.txt
			push "redirect-gateway def1 bypass-dhcp"
			push "dhcp-option DNS 173.230.155.5"
			push "dhcp-option DNS 173.255.212.5"
			push "dhcp-option DNS 173.255.219.5"
			push "dhcp-option DNS 173.255.241.5"
			push "dhcp-option DNS 173.255.243.5"
			push "dhcp-option DNS 173.255.244.5"
			push "dhcp-option DNS 173.230.145.5"
			push "dhcp-option DNS 173.230.147.5"
			push "dhcp-option DNS 74.207.241.5"
			push "dhcp-option DNS 74.207.242.5"
			keepalive 10 120
			cipher AES-256-CBC
			comp-lzo
			user nobody
			group nogroup
			persist-key
			persist-tun
			status openvpn-status.log
			verb 3
			crl-verify crl.pem" >> /etc/openvpn/server.conf		
			sudo systemctl start openvpn@server
			iptables-save > /etc/firewall.conf
			echo "#!/bin/sh
			iptables-restore < /etc/firewall.conf" >> /etc/network/if-up.d/iptables
			chmod +x /etc/network/if-up.d/iptables
            ;;
		"Openvpn klient centos7")
				echo "⚠️ Zaczekaj :-)"
				echo ""
				echo "Pamietaj najpierw wrzuc plik desktop.ovpn do katalogu /home"
				echo "jesli plik jest juz skopiowany wcisnij Y"
				echo ""
				until [[ $CONTINUE =~ (y|n) ]]; do
					read -rp "Continue? [y/n]: " -e CONTINUE
				done
				if [[ "$CONTINUE" = "n" ]]; then
					exit 1
				fi
			yum install nano wget -y
			sudo yum update -y
			cd /home
			sudo yum install openvpn -y
			sudo cp desktop.ovpn /etc/openvpn/client.conf
			sudo openvpn --client --config /etc/openvpn/client.conf
			sudo systemctl enable openvpn@client
			sudo systemctl start openvpn@client
			sudo journalctl --identifier openvpn
            ;;
		"Openvpn klient Debian")
			echo "⚠️ Zaczekaj :-)"
				echo ""
				echo "Pamietaj najpierw wrzuc plik desktop.ovpn do katalogu /home"
				echo "jesli plik jest juz skopiowany wcisnij Y"
				echo ""
				until [[ $CONTINUE =~ (y|n) ]]; do
					read -rp "Continue? [y/n]: " -e CONTINUE
				done
				if [[ "$CONTINUE" = "n" ]]; then
					exit 1
				fi
			sudo apt-get update -y
			sudo apt install openvpn
			cd /home
			sudo cp desktop.ovpn /etc/openvpn/client.conf
			sudo openvpn --client --config /etc/openvpn/client.conf
			sudo /etc/init.d/openvpn start
			sudo systemctl start openvpn@client
			;;
        "Routing podstawowy openvpn (na swiat)")
			#!/bin/bash
			echo "protokol  udp czy tcp"
			read protokol
			echo "wpisz port"
			read port
			echo "wpisz przyznany ip klienta openvpn np 10.8.0.2"
			read ip
			echo "wpisz publiczny ip serwera"
			read publicznyip
			iptables -A POSTROUTING -s $ip/24 -o tun0 -j MASQUERADE -t nat
			iptables -A POSTROUTING -s $ip/24 -o eth0 -j MASQUERADE -t nat
			iptables -A POSTROUTING -s $ip/24 -o eth0 -j SNAT --to-source $publicznyip -t nat
			iptables -A PREROUTING -i eth0 -p $protokol -m $protokol --dport $port -j DNAT --to-destination $ip:$port -t nat
			iptables-save > /etc/firewall.conf
		    ;;
		"routing zawansowany (na swiat)")
			#!/bin/bash
			echo "wpisz lokalny ip na jaki ma byc kierowany publiczny ip np 10.8.0.2 , 192.168.100.3"
			read lokalnyip
			echo "wpisz nazwe wirtualnej karty sieciowej np tun0 , vmbr2"
			read vkarta
			echo "wpisz drugo nazwe karty sieciowej np eth0 , eth1"
			read karta
			echo "na jakim protokole bedziesz pracowac udp czy tcp ?"
			read udptcp
			echo "wpisz port uslugi"
			read port
			echo "wpisz publiczny ip serwera"
			read publicznyip
			iptables -A POSTROUTING -s $lokalnyip/24 -o $vkarta -j MASQUERADE -t nat
			iptables -A POSTROUTING -s $lokalnyip/24 -o $karta -j MASQUERADE -t nat
			iptables -A POSTROUTING -s $lokalnyip/24 -o $karta -j SNAT --to-source $publicznyip -t nat
			iptables -A PREROUTING -i $karta -p $udptcp -m $udptcp --dport $port -j DNAT --to-destination $lokalnyip:$port -t nat
			iptables-save > /etc/firewall.conf
		    ;;
		"LXC PROXMOX DEB9")
			echo "deb http://download.proxmox.com/debian/pve stretch pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list
			wget http://download.proxmox.com/debian/proxmox-ve-release-5.x.gpg -O /etc/apt/trusted.gpg.d/proxmox-ve-release-5.x.gpg
			apt update && apt dist-upgrade -y
			deb [arch=amd64] http://download.proxmox.com/debian/pve stretch pve-no-subscription
			apt install proxmox-ve postfix open-iscsi -y
			apt remove os-prober
			apt remove linux-image-amd64 linux-image-4.9.0-3-amd64 -y
			update-grub
			echo "auto vmbr2
iface vmbr2 inet static
    address 192.168.100.1
    netmask 255.255.255.0
    bridge_ports none
    bridge_stp off
    bridge_fd 0
    post-up echo 1 > /proc/sys/net/ipv4/ip_forward
    post-up iptables -t nat -A POSTROUTING -s '192.168.100.0/24' -o eth0 -j MASQUERADE
    post-down iptables -t nat -D POSTROUTING -s '192.168.100.0/24' -o eth0 -j MASQUERADE" >> /etc/network/interfaces
	reboot
		    ;;
			"PROXMOX KVM")
			sudo apt install -y qemu-kvm libvirt0 virt-manager bridge-utils
			apt-get install qemu-guest-agent
			echo "⚠️ obrazy systemow wrzucaj do katalogu /var/lib/vz/template/iso"
		    ;;
			"CENTOS WEB PANEL")
			cd /usr/local/src
			wget http://centos-webpanel.com/cwp-el7-latest
			sh cwp-el7-latest
		    	;;
			"CPANEL")
			cd /home && curl -o latest -L https://securedownloads.cpanel.net/latest && sh latest
		    	;;
        "Quit")
            break
            ;;
        *) echo invalid option;;
    esac
done
