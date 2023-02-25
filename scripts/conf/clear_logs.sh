#!/bin/bash
cd /etc/pihole
sudo service pihole-FTL stop
sudo rm pihole-FTL.db
sudo service pihole-FTL start
cd $HOME

echo ""  > /var/log/unbound/unbound.log
