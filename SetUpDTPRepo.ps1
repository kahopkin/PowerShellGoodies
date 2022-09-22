git status

#clone into parent folder:
git clone https://github.com/microsoft/dtp.git


mkdir dtp
cd dtp
git init
git remote add origin https://github.com/microsoft/dtp.git
git branch -M main
git pull origin main
git fetch origin 

git checkout kahopkin\279-incorporate-the-wiki-repo-files-inside-the-main-repository-in-order-to-be-able-to-work-using-source-control

#Add a new remote URL pointing to the separate project: wiki.git.
git remote add -f wiki https://github.com/microsoft/dtp.wiki.git
#Merge the wiki project into the local Git project. 
#This doesn't change any of your files locally, but it does prepare Git for the next step.
git merge -s ours --no-commit --allow-unrelated-histories wiki/master
#Create a new directory called wiki,#and copy the Git history of the Spoon-Knife project into it.
git read-tree --prefix=wiki/ -u wiki/master
#Commit the changes to keep them safe.
git commit -m "Subtree wiki merged in main"

git push -u origin kahopkin\279-incorporate-the-wiki-repo-files-inside-the-main-repository-in-order-to-be-able-to-work-using-source-control

git checkout -b wiki wiki/master
git fetch wiki
git subtree pull --prefix wiki wiki master --squash --message="Merge wiki updates into docs."

git subtree push --prefix wiki wiki master

git pull  https://github.com/kahopkin/MainRepo.git main

git remote add origin https://github.com/kahopkin/MainRepo.git main

#touch .gitignore
#git add .gitignore
#git commit -m "initial commit"


git clone https://github.com/kahopkin/MainRepo.git
git clone https://github.com/microsoft/dtp.git


git remote remove wiki
git remote add wiki https://github.com/microsoft/dtp.wiki.git




git status

git add --all
git commit -m ""
git push -u origin update-wiki-from-main-repo
git subtree push --prefix wiki wiki master