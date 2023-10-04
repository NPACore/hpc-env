#!/usr/bin/env bash

# copy etc files we care about
rsync \
  cerebro2:/etc/{exports,fstab,hosts,systemd/system/guix-daemon.service} \
  etc/

if [[ $HOSTNAME =~ cerebro2 ]]; then
  # mkifdiff from lncdtools
  command -v mkifdiff >/dev/null || exit 1
  sudo crontab -l | mkifdiff -noempty etc/cron.root
fi

exit 0
