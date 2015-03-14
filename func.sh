#!/bin/bash
function menu(){
name="我的菜单"
author="create for wjc"
cat << eof
##########################################################
                                                        
                          `echo -e  "\033[31;40m$name\033[0m"`                      
                                                      
##########################################################
 `echo -e  "\033[31;40m author: \033[0m"`                                `echo -e  "\033[31;40m$author\033[0m"`                       
##########################################################

	1) add user
	2) set password for user
	3) delete a user
	4) print disk space
	5) print memory space
	6) quit
	7) return main menu

##########################################################


eof
}

function shellecho() {
	#$1=str,  $2=color1, $3=color2
	echo -e "\033[$2;$3m$1\033[0m"
}