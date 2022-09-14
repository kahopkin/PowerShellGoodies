﻿mkdir MainRepo
cd  MainRepo
git init
touch .gitignore
git add .gitignore
git commit -m "initial commit"
git remote add -f wiki https://github.com/kahopkin/WikiRepoTest.wiki.git
git merge -s ours --no-commit --allow-unrelated-histories wiki/master
git read-tree --prefix=wiki/ -u wiki/master
git commit -m "Subtree merged in main"


git fetch wiki --no-tags
git checkout -b wiki wiki/master
git read-tree --prefix=wiki/ -u wiki
git checkout wiki
git pull
git checkout master
git merge --squash -s recursive -Xsubtree=wiki wiki

git subtree pull --prefix docs docs master --squash --message="Merge wiki updates into docs."
git subtree push --prefix wiki wiki master