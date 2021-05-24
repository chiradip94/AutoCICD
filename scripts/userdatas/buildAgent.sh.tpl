#!/bin/bash

pip3 install virtualenv
mkdir /app
python3 -m venv /app
cd /app
source bin/activate
pip install git-remote-codecommit
yum install git -y
aws s3 cp s3://${bucket_name}/userdata/buildAgent.py buildAgent.py
