# Powershell-Delete-Users-30-Days-Disabled
Delete Disable Users Older than 30 Days with No Logon


Searches AD for users that are:

1. Disabled

2. Have not logged in for a minimum of 30 days

3. Not like *svc* (this is my designation for service accounts as I do not want to delete those)

It then adds all of those users to a csv file for reporting purposes.

The scrip then deletes all the users and emails out the results. 
