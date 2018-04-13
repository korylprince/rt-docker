#!/bin/bash

# set mailname
echo "$RT_SMTP_HOST" > /etc/smtpd/mailname

# generate smtpd.conf
rm /etc/smtpd/smtpd.conf

if [ -n "$RT_SMTP_TLS_CERT" ]; then
    echo "pki $RT_SMTP_HOST certificate \"$RT_SMTP_TLS_CERT\"" >> /etc/smtpd/smtpd.conf
    echo "pki $RT_SMTP_HOST key \"$RT_SMTP_TLS_KEY\"" >> /etc/smtpd/smtpd.conf
fi

cat >> /etc/smtpd/smtpd.conf <<EOF
listen on 0.0.0.0 port ${RT_SMTP_PORT} tag incoming ${RT_SMTP_TLS_OPT}
table aliases file:/etc/smtpd/aliases
accept from any tagged incoming for any alias <aliases>
accept from local for any relay via "${RT_SMTP_UPSTREAM}" ${RT_SMTP_UPSTREAM_OPT}
EOF

# generate aliases
rm /etc/smtpd/aliases
IFS=","
for alias in $(echo "$RT_ALIASES"); do
IFS=":" read -ra params <<< "$alias"
    echo "${params[0]}: |rt-mailgate --url http://localhost --action correspond --queue \"${params[1]}\"" >> /etc/smtpd/aliases
done

# start smtpd
smtpd -d &

# wait for db
while ! mysqladmin ping -h "$RT_DB_HOST" -P "$RT_DB_PORT" -u "$RT_DB_USER" -p="$RT_DB_PASS" --silent; do
    echo "database not ready yet. Waiting..."
    sleep 1
done

# start rt
exec rt-server --server Starman
