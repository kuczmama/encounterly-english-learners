#!/bin/bash
git stash;
bundle exec jekyll build;
git add .;
git commit -m "Automatic update with only jekyll build";
git push origin master;
git stash pop;