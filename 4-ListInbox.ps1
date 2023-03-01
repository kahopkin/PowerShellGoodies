<#
4-ListInbox.ps1
https://learn.microsoft.com/en-us/graph/tutorials/powershell?tabs=powershell&tutorial-step=4


#>

$user.DisplayName
Get-MgUserMailFolderMessage -UserId $user.Id -MailFolderId Inbox -Select `
  "from,isRead,receivedDateTime,subject" -OrderBy "receivedDateTime DESC" `
  -Top 25 | Format-Table Subject,@{n='From';e={$_.From.EmailAddress.Name}}, `
  IsRead,ReceivedDateTime



<#
5-Send Mail

#>
$sendMailParams = @{
    Message = @{
        Subject = "Testing Microsoft Graph"
        Body = @{
            ContentType = "text"
            Content = "Hello world!"
        }
        ToRecipients = @(
            @{
                EmailAddress = @{
                    Address = ($user.Mail ?? $user.UserPrincipalName)
                }
            }
        )
    }
}
Send-MgUserMail -UserId $user.Id -BodyParameter $sendMailParams