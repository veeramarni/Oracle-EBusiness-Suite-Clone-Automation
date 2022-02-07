// to decrypt password

echo "<encrypted pass>" | openssl aes-256-cbc -d -a -salt -k aes-256-cbc