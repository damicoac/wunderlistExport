Ruby script to export tasks from Wunderlist 2. Requires Ruby 1.9 or greater (tested and working with ruby 2.0), sqlite3 gem installed. Works on Mac only. Only tested with 10.8. Must be using the Mac App Store version of Wunderlist 2. Tested with with Wunderlist 2.0.5 and 2.1.0.

###Issues:
* Need more robust error checking
* Doesnt export subtasks properly
* Need to add command line arguements

###Usage:

The ruby script takes no arguements. The output directory that the Tasks to be output to is ~/Desktop. The script will make a file with all tasks in it. It is recommended that you exit Wunderlist 2 before running this script.

example:
```
 ruby wunderlistExport.rb
 ```

##Developer Notes:
wunderlist database name is = WKModel.sqlite

###wunderlist database structure
* select ZTITLE, znote, z_pk, ZTASKLIST from ZRESOURCE;
* Ztitle is task or list title
* z_pk is int identifier of ztitle if it is a list, if not then is is a iterated number
* ztasklist is the z_pk int of the tasks matching list, this is only true if the ztitle is a task and not a list
* zresouce is the table that holds all tasks and list
* znote is the note associated with a task
* list all projects : select ZTITLE, z_pk, ZTASKLIST from ZRESOURCE where ZTASKLIST is NULL;
* list all tasks : select ZTITLE, znote, ZTASKLIST from ZRESOURCE where ZTASKLIST is not NULL;
* if wunderlist is closed, this database can be edited and when wunderlist is opened it will reflect the new database but it will not sync those changes. This has something to do with the creationDate, syncStatus and changedDate attributes. I think these might be what keeps track of the changes and syncing of those changes.


