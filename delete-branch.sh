#!/bin/bash
git branch -d feature1
git push origin :feature1
git branch feature1
git checkout feature1
git push --set-upstream origin feature1
git checkout master
git push -u origin master:master
