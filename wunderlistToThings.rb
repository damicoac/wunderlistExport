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

extractPath = File.expand_path("~/Desktop/thingsImport.scpt")
exportFile = File.new(extractPath,"w")
exportFile << "tell application \"Things\"\n\n"

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

	exportFile << "    set newProject to make new project ¬\n"
	exportFile << "        with properties {name:\""+projectName+"\"} ¬\n"
	exportFile << "        at beginning of list \"Projects\"\n\n"

	wunderlistDatabase.execute("select ZTITLE, znote, zduedate, zcompletedat, ZTASKLIST from ZRESOURCE where ZTASKLIST=?",projectInt ) do |row|
			
		#convert date which is row[2]
		#puts row[0] 
		#puts row[1]
		task = row[0]
		note = row[1]
		dueDate = row[2]
		completedDate = row[3]
			
		if note == nil and dueDate == nil
			exportFile << "    tell project \""+projectName+"\"\n"
			exportFile << "        set newToDo to make new to do ¬\n"
			exportFile << "            with properties {name:\""+task+"\"}\n"
			exportFile << "    end tell\n\n"
		end
		if dueDate!= nil and note == nil
			time = Time.at(dueDate)
			correctDate = time.to_i()+978336000 #+11 years and 8 hours
			newTime = Time.at(correctDate)
			time = newTime.month.to_s() + "/" + newTime.day.to_s() + "/" + newTime.year.to_s()

			exportFile << "    tell project \""+projectName+"\"\n"
			exportFile << "        set newToDo to make new to do ¬\n"
			exportFile << "            with properties {name:\""+task+"\",due date:date \""+time+"\"}\n"
			exportFile << "    end tell\n\n"
				#puts row[2]
		end
		if note != nil and dueDate == nil
			exportFile << "    tell project \""+projectName+"\"\n"
			exportFile << "        set newToDo to make new to do ¬\n"
			exportFile << "            with properties {name:\""+task+"\", notes:\""+note+"\"}\n"
			exportFile << "    end tell\n\n"
		end
		if note != nil and dueDate != nil
			time = Time.at(dueDate)
			correctDate = time.to_i()+978336000 #+11 years and 8 hours
			newTime = Time.at(correctDate)
			time = newTime.month.to_s() + "/" + newTime.day.to_s() + "/" + newTime.year.to_s()

			exportFile << "    tell project \""+projectName+"\"\n"
			exportFile << "        set newToDo to make new to do ¬\n"
			exportFile << "            with properties {name:\""+task+"\",due date:date \""+time+"\", notes:\""+note+"\"}\n"
			exportFile << "    end tell\n\n"
		end
		taskTotal+=1
	end
	k+=1
end 

exportFile << "end tell\n"
exportFile.close()
puts "Done: " + taskTotal.to_s() + " Tasks Exported"	

#formate for apple script
#tell application "Things"
	
#	set newProject to make new project ¬
#		with properties {name:"Test", notes:"Tiny note"} ¬
#		at beginning of list "Projects"
	
#	tell project "Test"
#		set newToDo to make new to do ¬
#			with properties {name:"New to do for someday", due date:date "Tuesday, January 1, 2013 12:00:00 AM", notes:"this is a note"}
#	end tell
	
#end tell
