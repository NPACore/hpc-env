echo "TLS/SSL cert setup documentaton only"
exit 1

# 20240104
openssl pkcs12 -in fw.mrrc.upmc.edu.pfx -clcerts -nokeys -out fw.mrrc.upmc.edu.crt
openssl pkcs12 -in fw.mrrc.upmc.edu.pfx -nocerts -out fw.mrrc.upmc.edu.key
