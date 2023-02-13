
git remote add -f wiki https://github.com/microsoft/dtp.wiki.git


git merge -s ours --no-commit --allow-unrelated-histories wiki/master


git read-tree --prefix=wiki/ -u wiki/master


git add --all


git commit -m "message"


git push

git subtree push --prefix wiki wiki master


git pull -s subtree wiki master

