#!/bin/bash
#linux iptables command
#如果并发超过10, 那么就要按照我的规则(每分钟一个)来执行了!
iptables -A INPUT -p icmp -m limit --limit 1/m --limit-burst 10 -j ACCEPT
#其他icmp(ping请求)全部drop掉
iptables -A INPUT -p icmp -j DROP
