#!/bin/bash
mkdir -p .ssh
curl https://github.com/usatie.keys >> ~/.ssh/authorized_keys
curl https://github.com/hiroshi-kubota-rh.keys >> ~/.ssh/authorized_keys
curl https://github.com/nao215912.keys >> ~/.ssh/authorized_keys
