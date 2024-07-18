<#

How To Work With Multiple Github Accounts on your PC

https://gist.github.com/rahularity/86da20fe3858e6b311de068201d279e3

#>

git config user.email "katalin.hopkins@microsoft.com"
git config user.name "kahopkin"


#clone using ssh
git clone git@github.com:kahopkin/dtpResources.git

#add the remote origin to the project
git remote add origin git@github.com:kahopkin/dtpResources.git



git status
git add --all
git commit -m "message"
git push -u origin branchname