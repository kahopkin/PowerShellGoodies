Attribute VB_Name = "ContactFormat"

Sub UpdateContactFileAs()

'=================================================================
'Description: Outlook macro to change the File As format of all
'             contacts in the selected Contacts folder to a format
'             of choice.
'
'author : Robert Sparnaaij
'version: 1.0
'website: https://www.howto-outlook.com/howto/contactformat.htm
'=================================================================

    Dim FileAsFormat As String
    Dim CurrentFolder As Outlook.Folder
    Dim objItem As Object
    Dim objItems As Object
    Dim objContact As Outlook.ContactItem
    Set CurrentFolder = Application.ActiveExplorer.CurrentFolder
    
    If CurrentFolder.DefaultItemType = Outlook.olContactItem Then
        
        FileAsFormat = InputBox("Which File As format do you want to use?" _
                        & vbNewLine & "Type its number and press OK." _
                        & vbNewLine & vbNewLine & _
                        "1) Last, First" & vbNewLine & _
                        "2) First (Middle) Last (Suffix)" & vbNewLine & _
                        "3) First (Middle) Last" & vbNewLine & _
                        "4) First Last" & vbNewLine & _
                        "5) First Last (Company)" & vbNewLine & _
                        "6) Last, First (Company)" & vbNewLine & _
                        "7) Company (Last, First)" & vbNewLine & _
                        "8) Same as Full Name" & vbNewLine & _
                        "9) First Last [Company]" & vbNewLine & vbNewLine & _
                        "Note: Variables between parenthesis won't show " & _
                        "when they are not specified for the contact.", _
                        "Which File As format?")
        
        Set objItems = CurrentFolder.Items
        For Each objItem In objItems
            If objItem.Class = Outlook.olContact Then
                Set objContact = objItem
                
                With objContact
                
                    Select Case FileAsFormat
                        Case 1
                            .FileAs = .LastNameAndFirstName
                        Case 2
                            .FileAs = Trim(Trim(Trim(.FirstName & " " & .MiddleName) & " " & .LastName) & " " & .Suffix)
                        Case 3
                            .FileAs = Trim(Trim(.FirstName & " " & .MiddleName) & " " & .LastName)
                        Case 4
                            .FileAs = Trim(.FirstName & " " & .LastName)
                        Case 5
                            .FileAs = Trim(.FirstName & " " & .LastName) & .CompanyName
                        Case 6
                            .FileAs = .FullNameAndCompany
                        Case 7
                            .FileAs = .CompanyAndFullName
                        Case 8
                            .FileAs = .FullName
                        Case 9
                            .FileAs = Trim(Trim(.FirstName & " " & .MiddleName) & " " & .LastName & " [" & .CompanyName & "]")
                        Case Else
                            Result = MsgBox("No valid File As format selection" _
                                        , vbCritical, "File As format selection")
                            Exit Sub
                    End Select

                    .Save
                End With
            End If
        Next
        Result = MsgBox("Finished updating the File As format of all contacts." _
                        , vbInformation, "Done!")
    Else
        Result = MsgBox("Please select a Contacts folder." _
                    , vbCritical, "Select Contacts folder")
    End If
    
    Set CurrentFolder = Nothing
    Set objContact = Nothing
End Sub

Sub UpdateContactFullName()

'=================================================================
'Description: Outlook macro to change the Full Name format of all
'             contacts in the selected Contacts folder to the
'             chosen default in Outlook's options.
'
'author : Robert Sparnaaij
'version: 1.0
'website: https://www.howto-outlook.com/howto/contactformat.htm
'=================================================================

    Dim FileAsFormat As String
    Dim CurrentFolder As Outlook.Folder
    Dim objItem As Object
    Dim objItems As Object
    Dim objContact As Outlook.ContactItem
    Set CurrentFolder = Application.ActiveExplorer.CurrentFolder
    
    If CurrentFolder.DefaultItemType = Outlook.olContactItem Then
        
        Result = MsgBox("Update the Full Name field for all " & _
                    "your contacts according to your default " & _
                    "Full Name settings in Outlook?", _
                    vbQuestion + vbYesNo, "Update Full Name field")
                    
        If Result = vbYes Then
            Set objItems = CurrentFolder.Items
            For Each objItem In objItems
                If objItem.Class = Outlook.olContact Then
                    Set objContact = objItem
                    
                    'We need to touch something in one of the name
                    'field to force a rewrite of the Full Name field
                    'according to the default Full Name settings.
                    objContact.FirstName = objContact.FirstName
                    objContact.Save
                End If
            Next
            Result = MsgBox("Finished updating the Full Name format of all contacts." _
                , vbInformation, "Done!")
        End If
        
    Else
        Result = MsgBox("Please select a Contacts folder." _
                    , vbCritical, "Select Contacts folder")
    End If
    
    Set CurrentFolder = Nothing
    Set objContact = Nothing
End Sub


