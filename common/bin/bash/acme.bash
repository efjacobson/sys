#! /usr/bin/env bash
set -e

# haven't actually tried this as a script yet
# subdomain="$1"

# also needs the reloadcmd - think you can do that during issue: https://github.com/acmesh-official/acme.sh/blob/b7caf7a0165d80dd1556b16057a06bb32025066d/acme.sh#L7832

user='foo'
domain='bar' && \
subdomain='baz' && \
templatesubdomain='qux' && \
tld='wtf' && \
site="${subdomain}.${domain}.${tld}" && \
cp "/etc/nginx/sites-available/ha.${domain}.${tld}" "/etc/nginx/sites-available/${site}" && \
sed -i "s|${templatesubdomain}\.|${subdomain}\.|g" "/etc/nginx/sites-available/${site}" && \
sed -i "s|ssl_certificate|#ssl_certificate|g" "/etc/nginx/sites-available/${site}" && \
ln -s "/etc/nginx/sites-available/${site}" "/etc/nginx/sites-enabled/${site}" && \
cp -r "/var/www/${templatesubdomain}.${domain}.${tld}" "/var/www/${site}" && \
sed -i "s|${templatesubdomain}[[:space:]]dot|${subdomain} dot|g" "/var/www/${site}/index.html" && \
sed -i "s|acme[[:space:]]${templatesubdomain}[[:space:]]dot|acme ${subdomain} dot|g" "/var/www/${site}/.well-known/acme-challenge/index.html" && \
chown -R www-data:www-data "/var/www/${site}" && \
chmod -R 775 "/var/www/${site}" && \
systemctl restart nginx && \
runuser -u acme -- /etc/acme/.acme.sh/acme.sh --issue -d "${site}" -w "/var/www/${site}" && \
mkdir "/etc/nginx/ssl/${site}" && \
chown -R acme:acme "/etc/nginx/ssl/${site}" && \
runuser -u acme -- ln -s "/etc/acme/.acme.sh/${site}_ecc/${site}.key" "/etc/nginx/ssl/${site}/${site}.key" && ln -s "/etc/acme/.acme.sh/${site}_ecc/${site}.cer" "/etc/nginx/ssl/${site}/${site}.cer" && \
sed -i "s|#ssl_certificate|ssl_certificate|g" "/etc/nginx/sites-available/${site}" && \
systemctl restart nginx && \
runuser -u acme -- /etc/acme/.acme.sh/acme.sh --to-pkcs12 -d "${site}" && \
openssl pkcs12 -export -out "/etc/acme/.acme.sh/${site}_ecc/${site}.p12" \
	-certpbe AES-256-CBC \
    -keypbe AES-256-CBC -macalg SHA256 \
	-inkey "/etc/acme/.acme.sh/${site}_ecc/${site}.key" \
    -in "/etc/acme/.acme.sh/${site}_ecc/${site}.cer" \
	-certfile "/etc/acme/.acme.sh/${site}_ecc/ca.cer" \
	-password pass:"" && \
7z a "/home/${user}/${site}_ecc.7z" "/etc/acme/.acme.sh/${site}_ecc" -p -mhe=on && \
chown "${user}:${user}" "/home/${user}/${site}_ecc.7z" && \
echo "you have 60 seconds to run this command: scp ${user}@$(curl https://ipinfo.io/ip)/home/${user}/${site}_ecc.7z ./" && \
sleep 60 && \
rm "/home/${user}/${site}_ecc.7z"