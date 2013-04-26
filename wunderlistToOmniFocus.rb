#!/usr/bin/ruby
#requries ruby 1.9 and Macintosh OS X 10.7+. 
#tested with wunderlist 2

#import sqlite
require 'sqlite3'
require 'date'

#main

#read command line inputs
if ARGV.length !=0
    puts "Incorrect. Takes no arguements"
    exit
end

puts "Extracting . . . "

extractPath = File.expand_path("~/Desktop/omnifocusImport.scpt")
exportFile = File.new(extractPath,"w")
exportFile << "tell application \"OmniFocus\"\n\n"

#extraction logic
# locate wunderlist database
#wunderlistDb = File.expand_path("~/Documents/Code/wunderlistExport/reference db/WKModel.sqlite")
wunderlistDb = File.expand_path("~/Library/Containers/com.wunderkinder.wunderlistdesktop/Data/Library/Application Support/Wunderlist/WKModel.sqlite")
projectIntMap = Hash.new
hashIterator = Array.new

i = 0
k = 0
taskTotal = 0

#open database
wunderlistDatabase = SQLite3::Database.open(wunderlistDb)


#parse sqlite into a project to int value map
wunderlistDatabase.execute("select ZTITLE, z_pk, ZTASKLIST from ZRESOURCE where ZTASKLIST is NULL") do |row|
	#for each row
	#iterate through project list
	#get project name and int value
	projectIntMap.store(row[1], row[0])
	hashIterator[i] = row[1];
	i+=1
end

#puts projectIntMap
#puts hashIterator

while k < hashIterator.length

	#print out project name
	projectInt=hashIterator[k]
	projectName=projectIntMap[projectInt]
	
	#puts projectInt
	#puts projectName

	#exportFile << "    set newProject to make new project ¬\n"
	#exportFile << "        with properties {name:\""+projectName+"\"} ¬\n"
	#exportFile << "        at beginning of list \"Projects\"\n\n"

	wunderlistDatabase.execute("select ZTITLE, znote, zduedate, zcompletedat, ZTASKLIST from ZRESOURCE where ZTASKLIST=?",projectInt ) do |row|
			
		#convert date which is row[2]
		#puts row[0] 
		#puts row[1]
		task = row[0]
		note = row[1]
		dueDate = row[2]
		completedDate = row[3]
			
		if note != nil
			exportFile << "    tell front document\n"
			exportFile << "    set theContext to first flattened context where its name = \"Process\"\n"
        	exportFile << "    set theProject to first flattened project where its name = \"Input\"\n"
			exportFile << "        tell theProject to make new task with properties {name:\""+task+"\",note:\""+note+"\", context:theContext}\n"
			exportFile << "    end tell\n\n"
		end
		if note == nil
			exportFile << "    tell front document\n"
			exportFile << "    set theContext to first flattened context where its name = \"Process\"\n"
        	exportFile << "    set theProject to first flattened project where its name = \"Input\"\n"
			exportFile << "        tell theProject to make new task with properties {name:\""+task+"\", context:theContext}\n"
			exportFile << "    end tell\n\n"
		end
		taskTotal+=1
	end
	k+=1
end 

exportFile << "end tell\n"
exportFile.close()
puts "Done: " + taskTotal.to_s() + " Tasks Exported"	

#format for apple script
#	tell application "OmniFocus"
# 		tell the front document
#        set theContext to first flattened context where its name = "Tech"
#        set theProject to first flattened project where its name = "Finance"
#        tell theProject to make new task with properties  {name:theName,note:"made raw in PlainText, need to be checked"}
#		 end tell
#	end tell
