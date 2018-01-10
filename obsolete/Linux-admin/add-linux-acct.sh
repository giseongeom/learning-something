#!/bin/bash

# Changelog
#   0.1 (2017.12.08): initial release

export script_basename=`basename $0`
export target_acct_user_id=''
export target_acct_user_pw_encrypted=''
# See the following URLs
#  https://www.cyberciti.biz/tips/howto-write-shell-script-to-add-user.html
#  https://stackoverflow.com/questions/1020534/useradd-using-crypt-password-generation

ssh_pubkey_list="
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAzw7bHGg1snVZRiuGK0Ko74B6/qGpOKMz9wbpHpaWjyxF4GifvU6/y3zAQ/FGDr3wRMVPREeqDDLIbFWw2++KMCcmumbPyBtkJqItw5yv6r2sxLx+DJP4P6bpMSY8ov1NwbYHR2mBIe5pzgt94fCCqTJYuV1nnneoPTG3Cv9sKE7U66jkkJ6ISWzbLTvHFXUwtvpnotJjXLexNd51PWjwg0fsygJNe/HkDKvvb7ClDEpV1S5m7Z90hcEYPmWdV0ge4DOvbuxDpaxJSWMFc/CiqdJepKnzSwaAKT/f5+q4dWV9B+7Q5bpLo9iEq5jqj1t2yX0qx5aIEunLPl2qdOZGhw== tech_support@BLUEHOLE.net
\nssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA3T3wuhVb+HmZKiu52BpWFShes9okRt3puZRhWkfgFyDoLLFOTB8H+Ng+cbnCl69OzctmpMeafD+3D0QU3rEofM31GMNOfbzupe5aNv56FX4c7lHzROS3O364DCqCShFKvvAPZW0LmrXya4Tn8HQ/oP9b4ukIex0UT4M4XSbBVhLq0dMFwVZb8PpkQpFJudHm9SGAyEP87Cq2IcU0rcoFqCmjBcoV+9tF7rLeS72eddOkn7ZPMixUt8vkMJaAuxnq36v+I4f2In8Fn/ZR7ayrqKvJ5dtOwf4Ut7IynQxekgKqFXOX25NtK6uE3wovpcVwxqNN964anlgQGS7kPWbF8w== giseong.eom@bluehole.net
"

sudoers_config="
%${target_acct_user_id} ALL=(ALL) NOPASSWD:ALL
"


function _detect_sudo {
if [ "$(whoami)" = "root" ]; then
    export _is_sudo_enabled=true
    return 0
  else
    export _is_sudo_enabled=false
    return 255
fi
}

function _detect_linux_acct {
local _acct_exist=`grep -iw $1 /etc/passwd | wc -l`
if [[ $_acct_exist -eq 0 ]]; then
    return 0
  else
    return 255
fi
}


function _detect_linux_acct_dir {
local _acct_dir_exist=`ls -al /home | grep -iw $1 | wc -l`
if [[ $_acct_dir_exist -eq 0 ]]; then
    return 0
  else
    return 255
fi
}


function _add_user_acct {
useradd -m -G root -f -1 -s /bin/bash -p $2 $1
if [[ "$?" -eq 0 ]]; then
    return 0
  else
    return 255
fi
}


function _add_user_ssh_config {
local _user_home=/home/$1
if [[ -d "$_user_home" ]]; then
    mkdir -p $_user_home/.ssh
    chmod 700 $_user_home/.ssh
    echo -e $ssh_pubkey_list > $_user_home/.ssh/authorized_keys
    chmod 600 $_user_home/.ssh/authorized_keys
    chown -R $1:$1 $_user_home
    return 0
  else
    return 255
fi
}


function _add_user_sudo_config {
local _sudo_dir="/etc/sudoers.d"
if [[ -d $_sudo_dir ]]; then
    echo -e $sudoers_config > $_sudo_dir/99-user-$1
    chmod 440 $_sudo_dir/99-user-$1
    return 0
  else
    return 255
fi
}



################################################################################# 
### script main
################################################################################# 

echo -n "Detecting running as root: "
_detect_sudo
if [ "$?" -eq 0 ]; then
     echo "Yes"
   else
     echo "Failed" && echo -e "Running $0 requires root or sudo  \nExiting..."
     echo ''
     exit 255
fi


echo -n "Checking account $target_acct_user_id: "
_detect_linux_acct $target_acct_user_id
if [ "$?" -eq 0 ]; then
     echo "None"
  else
     echo "Found" && echo -e "account $target_acct_user_id is aleady exist. \nExiting..."
     echo ''
     exit 255
fi


echo -n "Checking account $target_acct_user_id HOME: "
_detect_linux_acct_dir $target_acct_user_id
if [ "$?" -eq 0 ]; then
     echo "None"
  else
     echo "Found" && echo -e "account $target_acct_user_id HOME aleady exist. \nExiting..."
     echo ''
     exit 255
fi


echo -n "Creating account $target_acct_user_id: "
_add_user_acct $target_acct_user_id $target_acct_user_pw_encrypted
if [ "$?" -ne 0 ]; then
     echo "Failed" && echo -e "account $target_acct_user_id failed to create. \nExiting..."
     echo ''
     exit 255
fi
_add_user_ssh_config $target_acct_user_id
if [ "$?" -ne 0 ]; then
     echo "Failed" && echo -e "account $target_acct_user_id failed to create. \nExiting..."
     echo ''
     exit 255
fi
_add_user_sudo_config $target_acct_user_id
if [ "$?" -eq 0 ]; then
     echo "Done"
  else
     echo "Failed" && echo -e "account $target_acct_user_id failed to create. \nExiting..."
     echo ''
     exit 255
fi

 