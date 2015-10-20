#!/bin/bash

ls ~/.ssh/id_rsa* 2>/dev/null || echo "" | ssh-keygen -t rsa -b 4096 -C "ibalutoiu@cloudbasesolutions.com" -N ""
