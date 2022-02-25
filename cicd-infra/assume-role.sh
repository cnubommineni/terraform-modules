#!/usr/bin/env bash

set -x
#set -e

role_arn='arn:aws:iam::587219698707:role/GroupAccess-Admin'
role_session_name='GroupAccess-Admin'
profile_name='prod'

temp_role=$(aws sts assume-role \
     --role-arn $role_arn \
     --role-session-name $role_session_name)

export AWS_ACCESS_KEY_ID=$(echo $temp_role | jq -r .Credentials.AccessKeyId)
export AWS_SECRET_ACCESS_KEY=$(echo $temp_role | jq -r .Credentials.SecretAccessKey)
export AWS_SESSION_TOKEN=$(echo $temp_role | jq -r .Credentials.SessionToken)

aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID --profile $profile_name
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY --profile $profile_name
aws configure set aws_session_token $AWS_SESSION_TOKEN --profile $profile_name