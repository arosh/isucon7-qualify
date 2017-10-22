#!/bin/bash
set -ex
now=`date +%Y%m%d-%H%M%S`
curl -X POST --data-urlencode "payload={\"text\": \"\`\`\`\nAPP RELOAD START!!!!(${now})\n\`\`\`\"}" https://hooks.slack.com/services/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

if [ -e /var/log/nginx/access.log ]; then
  mv /var/log/nginx/access.log /var/log/nginx/access.log.$now
fi

if [ -e conf/sysctl.conf ]; then
  cp conf/sysctl.conf /etc/sysctl.conf
fi
sysctl -p

if [ -e conf/nginx.conf ]; then
  cp conf/nginx.conf /etc/nginx/nginx.conf
fi
systemctl reload nginx

if [ -e conf/isubata.python.service ]; then
  cp conf/isubata.python.service /etc/systemd/system/isubata.python.service
fi

systemctl daemon-reload
systemctl restart isubata.python

now=`date +%Y%m%d-%H%M%S`
curl -X POST --data-urlencode "payload={\"text\": \"\`\`\`\nAPP RELOAD END!!!!(${now})\n\`\`\`\"}" https://hooks.slack.com/services/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
journalctl -f -u nginx -u isubata.python
