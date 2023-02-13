#new
echo "# MainRepo" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/kahopkin/MainRepo.wiki.git
https://github.com/kahopkin/MainRepo.git
https://github.com/kahopkin/MainRepo.wiki.git
git push -u origin main


#push an existing repository from the command line
git remote add origin https://github.com/kahopkin/MainRepo.git
git branch -M main
git push -u origin main


#Add a new remote URL pointing to the separate project: wiki.git.
git remote add -f wiki https://github.com/kahopkin/MainRepo.wiki.git

#Merge the wiki project into the local Git project. 
#This doesn't change any of your files locally, but it does prepare Git for the next step.
git merge -s ours --no-commit --allow-unrelated-histories wiki/master
#Create a new directory called wiki,#and copy the Git history of the Spoon-Knife project into it.
git read-tree --prefix=wiki/ -u wiki/master
#Commit the changes to keep them safe.
git commit -m "Subtree wiki merged in main"

git push -u origin main


# pull the wiki subtree
git pull -s subtree wiki master