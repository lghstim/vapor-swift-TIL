#!/bin/bash
# Deploys a Vapor project to an EC2 instance
#
# run with ./deploy.sh SERVER_IP
# Example:
# ./deploy.sh ec2-12-34-456-890.compute-1.amazonaws.com

ARCHIVE="/tmp/app.zip"
FOLDER="~/app"

echo "starting deployment to $1"

echo "zipping the project’s Git HEAD to $ARCHIVE"
git archive -o $ARCHIVE HEAD

echo "uploading to $1, please wait"
scp -r -i "tim_gpu.pem" $ARCHIVE ubuntu@ec2-54-145-200-212.compute-1.amazonaws.com:/tmp/

echo "optionally (re)creating folder $FOLDER on server"
CMD="mkdir -p $FOLDER"
ssh -i "tim_gpu.pem" ubuntu@ec2-54-145-200-212.compute-1.amazonaws.com $CMD

echo "unzipping uploaded file to $FOLDER on server"
CMD="unzip -o -q $ARCHIVE -d $FOLDER"
ssh -i "tim_gpu.pem" ubuntu@ec2-54-145-200-212.compute-1.amazonaws.com $CMD

echo "deleting optionally existing .gitignore & .travis.yml on server"
CMD="cd $FOLDER && rm -f .gitignore* && rm -f .travis*"
ssh -i "tim_gpu.pem" ubuntu@ec2-54-145-200-212.compute-1.amazonaws.com  $CMD

echo "building project, please wait"
CMD="cd $FOLDER"
ssh -i "tim_gpu.pem" ubuntu@ec2-54-145-200-212.compute-1.amazonaws.com "bash -lc \"$CMD\""

echo "restarting service"
CMD="sudo systemctl restart app"
ssh -i "tim_gpu.pem" ubuntu@ec2-54-145-200-212.compute-1.amazonaws.com  $CMD

echo "service status:"
CMD="sudo systemctl status app"
ssh -i "tim_gpu.pem" ubuntu@ec2-54-145-200-212.compute-1.amazonaws.com  $CMD

echo "Finished!"
