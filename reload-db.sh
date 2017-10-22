#!/bin/bash
set -ex
now=`date +%Y%m%d-%H%M%S`
curl -X POST --data-urlencode "payload={\"text\": \"\`\`\`\nDB RELOAD START!!!!(${now})\n\`\`\`\"}" https://hooks.slack.com/services/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

if [ -e /var/log/nginx/access.log ]; then
  mv /var/log/nginx/access.log /var/log/nginx/access.log.$now
fi

if [ "$(pgrep mysql | wc -l)" ]; then
  mysqladmin -uroot flush-logs
fi

if [ -e /var/log/mysql/mysql-slow.log ]; then
  mv /var/log/mysql/mysql-slow.log /var/log/mysql/mysql-slow.log.$now
fi

if [ -e conf/sysctl.conf ]; then
  cp conf/sysctl.conf /etc/sysctl.conf
fi
sysctl -p

if [ -e conf/nginx.conf ]; then
  cp conf/nginx.conf /etc/nginx/nginx.conf
fi
systemctl reload nginx

if [ -e conf/my.cnf ]; then
  cp conf/my.cnf /etc/mysql/my.cnf
fi
systemctl restart mysql

if [ -e conf/isubata.python.service ]; then
  cp conf/isubata.python.service /etc/systemd/system/isubata.python.service
fi

systemctl daemon-reload
systemctl restart isubata.python

now=`date +%Y%m%d-%H%M%S`
curl -X POST --data-urlencode "payload={\"text\": \"\`\`\`\nDB RELOAD END!!!!(${now})\n\`\`\`\"}" https://hooks.slack.com/services/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
journalctl -f -u mysql -u nginx -u isubata.python
