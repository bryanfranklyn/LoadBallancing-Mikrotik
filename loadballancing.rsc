
/interface ovpn-client
add connect-to=[server ovpn] mac-address=[mac] name=[name] \
    password=[pass] user=user
	
/interface ethernet
set [ find default-name=ether1 ] name=ether1-ISP1
set [ find default-name=ether2 ] name=ether2-SWITCH
set [ find default-name=ether3 ] name=ether3-PPPOE
set [ find default-name=ether4 ] disabled=yes


/ip pool
add name=pppoe ranges=[ip]
add name=swicth ranges=[ip]


/ip dhcp-server
add address-pool=dhcp_pool3 disabled=no interface=ether2-SWITCH name=dhcp1

/ppp profile
set *0 dns-server=[dns] local-address=pppoe only-one=yes remote-address=\
    pppoe wins-server=[dns]
	
/interface detect-internet
set detect-interface-list=all

/interface pppoe-server server
add disabled=no interface=ether3-PPPOE one-session-per-host=yes service-name=\
    lembah
	
/ip address
add address=[ip]/24 interface=ether2-SWITCH network=[ip]
add address=[ip]/24 interface=ether3-PPPOE network=[ip]

/ip dhcp-client
add disabled=no interface=ether1-ISP1 use-peer-dns=no
add disabled=no interface=wlan1-ISP2

/ip dhcp-server network
add address=[ip]/24 dns-server=[dns,dns] gateway=[ipgetway]

/ip dns
set allow-remote-requests=yes servers=[dns]

/ip firewall address-list
add address=[ip]/24 list=switch
add address=[ip]/24 list=pppoe

/ip firewall mangle
add action=mark-connection chain=input in-interface=ether1-ISP1 \
    new-connection-mark=isp-1 passthrough=yes
add action=mark-connection chain=input in-interface=wlan1-ISP2 \
    new-connection-mark=isp-2 passthrough=yes
add action=mark-routing chain=output comment=OUTOUT-SWICTH connection-mark=\
    isp-1 new-routing-mark=KE-ISP-1 passthrough=yes
add action=mark-routing chain=output connection-mark=isp-2 new-routing-mark=\
    KE-ISP-2 passthrough=yes
add action=mark-routing chain=output comment=OUTOUT-PPPOE connection-mark=\
    isp-1 new-routing-mark=KE-ISP-1-PPPOE passthrough=yes
add action=mark-routing chain=output connection-mark=isp-2 new-routing-mark=\
    KE-ISP-2-PPPOE passthrough=yes
add action=accept chain=prerouting comment="ACCEPT ALL" in-interface=\
    ether1-ISP1
add action=accept chain=prerouting in-interface=wlan1-ISP2
add action=mark-connection chain=prerouting comment="MARK SWITCH" \
    dst-address-type=!local new-connection-mark=isp-1 passthrough=yes \
    per-connection-classifier=both-addresses-and-ports:2/0 src-address-list=\
    switch
add action=mark-connection chain=prerouting dst-address-type=!local \
    new-connection-mark=isp-2 passthrough=yes per-connection-classifier=\
    both-addresses-and-ports:2/1 src-address-list=switch
add action=mark-routing chain=prerouting connection-mark=isp-1 \
    new-routing-mark=KE-ISP-1 passthrough=yes
add action=mark-routing chain=prerouting connection-mark=isp-2 \
    new-routing-mark=KE-ISP-2 passthrough=yes
add action=mark-connection chain=prerouting comment="MARK PPPOE" \
    connection-state=new dst-address-type=!local new-connection-mark=isp-1 \
    passthrough=yes per-connection-classifier=both-addresses-and-ports:2/0 \
    src-address-list=pppoe
add action=mark-connection chain=prerouting connection-state=new \
    dst-address-type=!local new-connection-mark=isp-2 passthrough=yes \
    per-connection-classifier=both-addresses-and-ports:2/1 src-address-list=\
    pppoe
add action=mark-routing chain=prerouting connection-mark=isp-1 \
    new-routing-mark=KE-ISP-1-PPPOE passthrough=yes
add action=mark-routing chain=prerouting connection-mark=isp-2 \
    new-routing-mark=KE-ISP-2-PPPOE passthrough=yes
	
/ip firewall nat
add action=masquerade chain=srcnat out-interface=ether1-ISP1
add action=masquerade chain=srcnat out-interface=wlan1-ISP2
add action=masquerade chain=srcnat out-interface=ovpn-out1
add action=masquerade chain=srcnat out-interface=ether3-PPPOE

/ip route
add check-gateway=ping distance=1 gateway=[ipgetway] routing-mark=KE-ISP-1
add check-gateway=ping distance=1 gateway=[ipgetway] routing-mark=KE-ISP-2
add check-gateway=ping distance=1 gateway=[ipgetway] routing-mark=\
    KE-ISP-1-PPPOE
add check-gateway=ping distance=1 gateway=[ipgetway] routing-mark=\
    KE-ISP-2-PPPOE
add check-gateway=ping distance=1 gateway=[ipgetway-isp1],[ipgetway-isp2]
add check-gateway=ping distance=1 gateway=[ipgetway]
add check-gateway=ping distance=1 gateway=[ipgetway]
add distance=1 dst-address=[ipOvpn] gateway=[ipgetway]

/ip service
set telnet disabled=yes
set ftp disabled=yes
set ssh disabled=yes
set api disabled=yes
set api-ssl disabled=yes

/ppp secret
add name=[name] password=[pass] service=pppoe

/system clock
set time-zone-name=Asia/Jakarta

/system identity
set name=[name]
