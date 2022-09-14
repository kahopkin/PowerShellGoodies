#When created a branch on GitHub, run in local clone:
git fetch origin
#git checkout <NewBranchName>
git checkout kahopkins\279-incorporate-the-wiki-repo-files-inside-the-main-repository-in-order-to-be-able-to-work-using-source-control

#Synchronize your local repository with the remote repository on GitHub.com
$ git fetch
#Downloads all history from the remote tracking branches
$ git merge
#Combines remote tracking branches into current local branch
$ git push
#Uploads all local branch commits to GitHub
$ git pull


#To see all remote branch names, run 
git branch -r

#To see all local and remote branches, run 
git branch -a

<#
You can see detailed information such as 
the local or remote branches in use, commit ids, and commit messages by running 
#>
git branch -vv 
git branch -vva

#Make changes
#Browse and inspect the evolution of project files
$ git log
#Lists version history for the current branch
$ git log --follow [file]
#Lists version history for a file, beyond renames (works only for a single file)
$ git diff [first-branch]...[second-branch]
#Shows content differences between two branches
$ git show [commit]
#Outputs metadata and content changes of the specified commit
$ git add [file]
#Snapshots the file in preparation for versioning
$ git commit -m "[descriptive message]"

#Records file snapshots permanently in version history


#Redo commits
#Erase mistakes and craft replacement history
$ git reset [commit]
#Undoes all commits after [commit], preserving changes locally
$ git reset --hard [commit]
#Discards all history and changes back to the specified commit

#Use git status to see which branch that is.
$ git status
#Creates a new branch
$ git branch [branch-name]
#Switches to the specified branch and updates the working directory
$ git switch -c [branch-name]
#Combines the specified branch’s history into the current branch. This is usually done in pull requests, but is an important Git operation.
$ git merge [branch]
#Deletes the specified branch
$ git branch -d [branch-name]

