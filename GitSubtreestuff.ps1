mkdir testproject
cd  testproject
git init
# from gitbash:
touch .gitignore
#from PS ISE or anywhere else
#echo "# testproject" >> README.md
echo "# testproject" >> .gitignore
git add .gitignore
git commit -m "initial commit"


#1
git checkout update-wiki-from-main-repo
#Add a new remote URL pointing to the separate project: wiki.git.
git remote add -f wiki https://github.com/microsoft/dtp.wiki.git

#Merge the wiki project into the local Git project. 
#This doesn't change any of your files locally, but it does prepare Git for the next step.
git merge -s ours --no-commit --allow-unrelated-histories wiki/master

#Create a new directory called wiki,
#and copy the Git history of the wiki.git's files into it.
git read-tree --prefix=wiki/ -u wiki/master

#Commit the changes to keep them safe.
git commit -m "Subtree merged in my branch"

#git push -u origin <YourBranch>
git push -u origin kahopkin-wiki-from-main-repo
#git push -u origin update-wiki-from-main-repo
git subtree push --prefix wiki wiki master

git status
git add --all
git commit -m "message"
git push -u origin branchname
git subtree push --prefix wiki wiki master



#When a subproject is added, it is not automatically kept in sync with the upstream changes. You will need to update the subproject with the following command:
git pull -s subtree remotename branchname
#For the dtp, this would be:
git pull -s subtree wiki master



git push -u origin main


git remote add wiki https://github.com/<user>/<repo>.wiki.git
git remote add wiki https://github.com/kahopkin/MainRepo.wiki.git
git remote add wiki https://github.com/kahopkin/katwiki.wiki.git
git subtree pull --prefix wiki wiki master --squash --message="Merge wiki updates into docs."

git pull -s subtree wiki master




git subtree pull --prefix docs wiki master --squash --message="Merge wiki updates into docs."
git subtree pull --prefix wiki wiki master --squash --message="Merge wiki updates into docs."




#MAKE changes in the main/wiki and push to remote:
git subtree pull --prefix wiki wiki master --squash --message="Merge wiki updates into docs."
git subtree push --prefix wiki wiki master


#push changes in main repo's wiki to the remote wiki:
git subtree push --prefix wiki wiki master


1#create repo on command line and push to repo created on github:
mkdir testproject
cd  .\testproject
git init
echo "# testproject" >> README.md
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/kahopkin/dtpResources.git
git push -u origin main


git remote add https://github.com/kahopkin/WikiRepoTest.wiki.git



git branch -M main
git remote add origin https://github.com/kahopkin/testproject.git
git push -u origin main




https://github.com/kahopkin/MainRepo.git
https://github.com/kahopkin/MainRepo.wiki.git

git push -u origin main



#git merge -s ours --allow-unrelated-histories wiki/main

git read-tree --prefix=wiki/ -u wiki/master
git commit -m "Subtree merged in testproject"

git pull -s subtree wiki master

git subtree push --prefix wiki  wiki main

git merge -s ours --allow-unrelated-histories wiki/main


git subtree push --prefix wiki wiki master




echo "# TestMainProject" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/kahopkin/TestMainProject.git
git push -u origin main


https://github.com/kahopkin/TestMainProject.git
https://github.com/kahopkin/TestMainProject.wiki.git

git remote add wiki https://github.com/kahopkin/TestMainProject.wiki.git

git subtree add --prefix wiki https://github.com/kahopkin/TestMainProject.wiki.git master --squash
git subtree push --prefix wiki https://github.com/kahopkin/TestMainProject.wiki.git master


