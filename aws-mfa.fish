#!/usr/bin/env fish

set PRE_ID (cat ~/.aws/credentials | grep -FA2 $argv[1] | awk '/aws_access_key_id/ {print $3}')
set PRE_KEY (cat ~/.aws/credentials | grep -FA2 $argv[1] | awk '/aws_secret_access_key/ {print $3}')
echo PRE_ID=$PRE_ID
echo PRE_KEY=$PRE_KEY

set mfacode $argv[2]
echo mfacode=$mfacode

set -x AWS_ACCESS_KEY_ID $PRE_ID
echo $AWS_ACCESS_KEY_ID
set -x AWS_SECRET_ACCESS_KEY $PRE_KEY
echo $AWS_SECRET_ACCESS_KEY
set --erase AWS_SESSION_TOKEN

set arn (aws sts get-caller-identity --output text --query Arn | sed 's|:user/|:mfa/|')
echo $arn
set json (aws sts get-session-token --serial-number $arn --token-code $mfacode)
echo $json | jq .

set -x AWS_ACCESS_KEY_ID (echo $json | jq -r .Credentials.AccessKeyId)
set -x AWS_SECRET_ACCESS_KEY (echo $json | jq -r .Credentials.SecretAccessKey)
set -x AWS_SESSION_TOKEN (echo $json | jq -r .Credentials.SessionToken)
set -x AWS_SECURITY_TOKEN $AWS_SESSION_TOKEN

set --erase AWS_PROFILE

env | grep '^AWS_' | sed 's/^/export /'
