#!/bin/bash
#iptables full rules
#brave 2015-6-3
#########################################
#加载一些内核模块
modprobe ipt_MASQUERADE
modprobe ip_conntrack_ftp
modprobe ip_nat_ftp
#清空所有规则
iptables -F
iptables -t nat -F
iptables -X
iptables -t nat -X
########################################
#-P 表示默认规则的设置
iptables -P INPUT DROP
#允许一些监听的地址访问
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

iptables -A INPUT -i lo -j ACCEPT

iptables -A INPUT -p tcp -m multiport -dports 110,80,25 -j ACCEPT
#允许samba协议访问
iptables -A INPUT -p tcp -s 10.10.0.0/24 --dport 139 -j ACCEPT   

#允许eth1网卡上走udp协议的dns服务访问
iptables -A INPUT -i eth1 -p udp -m multiport -dport 53 -j ACCEPT

#针对vpn的访问规则
#ppept协议端口1723
iptables -A INPUT -p tcp --dport 1723 -j ACCEPT
#一个虚拟隧道协议
iptables -A INPUT -p gre -j ACCEPT

#允许一些处于建立和有关系的链接访问
iptables -A INPUT -s 192.168.0.0/24 -p tcp -m state --state	ESTABLISHED,RELATED -j ACCEPT
#ppp0,一个拨号设备
iptables -A INPUT -i ppp0 -p tcp --syn -m connlimit --connlimit-above 15 -j DROP

#封闭icmp协议的访问
iptables -A INPUT -p icmp -j DROP

###################################
#nat 转发, 控制所有内网的机器如果走外网,就要通过ppp0出去
iptables -t nat -A POSTROUTING -o ppp0 -s 10.10.0.0/24 -j MASQUERADE

#针对syn攻击的一些限制, 效果不是很好
iptables -N syn-flood
iptables -A INPUT -p tcp --syn -j syn-flood
iptables -I syn-flood -p tcp -m limit --limit 3/s --limit-burst 6 -j RETURN
iptables -A syn-flood -j REJECT

#对于内网的一些设置
iptables -P FORWARD DROP
iptables -A FORWARD -p tcp -s 10.10.0.0/24 -m multiport --dport 80,110,21,25,1723 -j ACCEPT
iptables -A FORWARD -p udp -s 10.10.0.0/24 --dport 53 -j ACCEPT
iptables -A FORWARD -p gre -s 10.10.0.0/24 -j ACCEPT
iptables -A FORWARD -p icmp -s 10.10.0.0/24 -j ACCEPT

#上班期间禁止大家上qq,taobao等类似网站规则配置,设置53 dns 端口
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -I FORWARD -p udp --dport 53 -m string --string "tencent" -m time --timestart 8:15 --timestop 12:30 --days Mon,Tue,Wed,Thu,Fri,Sat -j DROP

iptables -I FORWARD -p udp --dport 53 -m string --string "TENCENT" -m time --timestart 8:15 --timestop 12:30 --days Mon,Tue,Wed,Thu,Fri,Sat -j DROP

iptables -I FORWARD -p udp --dport 53 -m string --string "tencent" -m time --timestart 13:30 --timestop 20:30 --days Mon,Tue,Wed,Thu,Fri,Sat -j DROP

iptables -I FORWARD -p udp --dport 53 -m string --string "TENCENT" -m time --timestart 13:30 --timestop 20:30 --days Mon,Tue,Wed,Thu,Fri,Sat -j DROP

iptables -I FORWARD -s 10.10.0.0/24 -m string --string "qq.com" -m time --timestart 8:15 --timestop 12:30 --days Mon,Tue,Wed,Thu,Fri,Sat -j DROP

iptables -I FORWARD -s 10.10.0.0/24 -m string --string "qq.com" -m time --timestart 13:00 --timestop 20:30 --days Mon,Tue,Wed,Thu,Fri,Sat -j DROP

iptables -I FORWARD -s 10.10.0.0/24 -m string --string "苍老师" -j DROP
iptables -I FORWARD -d 10.10.0.0/24 -m string --string "苍老师等字符串" -j DROP

#内核模块
sysctl -w net.ipv4.ip_forward=1 &>/dev/null
sysctl -w net.ipv4.tcp_syncookies=1 &>/dev/null

#允许本机访问所有的权限
iptables -I INPUT -s 10.10.0.50 -j ACCEPT
iptables -I FORWARD -s 10.10.0.50 -j ACCEPT


