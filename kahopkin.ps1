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


git remote add origin https://github.com/microsoft/dtp.git
git branch -M main
git pull origin main
git fetch origin 



cd C:\Github
mkdir PowerShellGoodies
cd PowerShellGoodies
git init

git config user.email "katalin.hopkins@microsoft.com"
git config user.name "kahopkin"


#clone using ssh
git clone git@github.com:kahopkin/PowerShellGoodies.git

#add the remote origin to the project
git remote add origin git@github.com:kahopkin/PowerShellGoodies.git

git branch -M main
git pull origin main
git fetch origin 


git status
git add --all
git commit -m "message"
git push -u origin branchname