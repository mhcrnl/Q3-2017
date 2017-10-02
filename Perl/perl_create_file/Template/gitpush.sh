#!/bin/bash 
DATE=`date` 
git add . 
git commit -m $DATE \ngit push origin master 
