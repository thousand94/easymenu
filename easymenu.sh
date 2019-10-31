#!/bin/bash

PS3='Please enter your choice: '
options=("Openvpn serwer centos7" "Openvpn serwer debian9" "Openvpn klient centos7" "Openvpn klient Debian" "Routing podstawowy openvpn (na swiat)" "routing zawansowany (na swiat)" "Quit")
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
      echo "you chose choice 2"
			sudo apt-get update -y
			sudo apt-get upgrade -y
			sudo apt-get install ufw
			sudo ufw allow 22
			sudo ufw allow 80
			sudo ufw allow 443
			sudo ufw enable
			sudo ufw status
			wget https://git.io/vpn -O openvpn-install.sh
			sudo bash openvpn-install.sh
			cat /etc/rc.local
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
        "Quit")
            break
            ;;
        *) echo invalid option;;
    esac
done
