#!/bin/bash

sudo fstrim -v /

sudo systemctl enable fstrim.timer

sudo systemctl start fstrim.timer

systemctl status fstrim.timer
