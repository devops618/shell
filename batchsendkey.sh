while read ip; do
  user="root"
  passwd="passwd"
  expect <<EOF
      set timeout 3
      spawn ssh-copy-id -i /root/.ssh/id_rsa.pub $user@$ip
      expect {
        "yes/no" { send "yes\n";exp_continue }
        "password" { send "$passwd\n" }
      }
      expect "password" { send "$passwd\n" }
EOF
done <host
