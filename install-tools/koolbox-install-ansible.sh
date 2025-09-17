#!/usr/bin/bash

# Do not use ansible 10.3.0 since ansible 10 does not support python 2.7 and 3.6 for remote execution
# See: https://docs.ansible.com/ansible/latest/porting_guides/porting_guide_10.html
pip3 install --break-system-packages \
    ansible==9.9.0 \
    ansible-lint==24.7.0 \
    pre-commit==3.8.0 \
    hvac==2.3.0 \
    jq==1.8.0 \

rm -rf .cache/pip
