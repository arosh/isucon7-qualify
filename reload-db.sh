#!/bin/bash
set -ex
now=`date +%Y%m%d-%H%M%S`
curl -X POST --data-urlencode "payload={\"text\": \"\`\`\`\nDB RELOAD START!!!!(${now})\n\`\`\`\"}" https://hooks.slack.com/services/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

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

if [ -e conf/my.cnf ]; then
  cp conf/my.cnf /etc/mysql/my.cnf
fi
systemctl restart mysql

now=`date +%Y%m%d-%H%M%S`
curl -X POST --data-urlencode "payload={\"text\": \"\`\`\`\nDB RELOAD END!!!!(${now})\n\`\`\`\"}" https://hooks.slack.com/services/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
journalctl -f -u mysql
