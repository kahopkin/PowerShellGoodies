#Set permission up to write to Synology
cmdkey /add:10.20.30.30 /user:10.20.30.30\katalinhopkins /pass:Cogito@rgo5um
#cmdkey /add:\\DS224 /user:DS224\katalinhopkins /pass:Cogito@rgo5um

#robocopy "C:\Users\kahopkin\Music" "C:\Users\kahopkin\OneDrive - Microsoft\Music" /S /ETA /COPYALL /DCOPY:DAT /R:3 /W:3 /MT:16 