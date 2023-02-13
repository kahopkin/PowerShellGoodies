#create a new repository on the command line
echo "# HomeRepo" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/kahopkin/HomeRepo.git
git push -u origin main

#push an existing repository from the command line
git remote add origin https://github.com/kahopkin/HomeRepo.git
git branch -M main
git push -u origin main


#Main repo
https://github.com/kahopkin/HomeRepo

#wiki repo
https://github.com/kahopkin/HomeRepo.wiki.git


#Use git status to see which branch that is.
git status
#Creates a new branch
git branch wikisynctest
#Switches to the specified branch and updates the working directory
git switch -c wikisynctest


#Add a new remote URL pointing to the separate project: wiki.git.
git remote add -f wiki https://github.com/kahopkin/HomeRepo.wiki.git


#Merge the wiki project into the local Git project. 
#This doesn't change any of your files locally, but it does prepare Git for the next step.
git merge -s ours --no-commit --allow-unrelated-histories wiki/master

#Create a new directory called wiki,
#and copy the Git history of the wiki.git's files into it.
git read-tree --prefix=wiki/ -u wiki/master

#Commit the changes to keep them safe.
git commit -m "Subtree merged in my branch"

#git push -u origin <YourBranch>
git push -u origin wikisynctest

