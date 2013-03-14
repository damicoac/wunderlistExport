#!/usr/bin/ruby
#requries ruby 1.9 and Macintosh OS X 10.7+. 
#tested with wunderlist 2

#import sqlite
require 'sqlite3'
require 'date'

#main

#read command line inputs
if ARGV.length !=1
    puts "Incorrect Arguments. Only one arguement required : path for extracted highlights to be saved."
    exit
end

extractPath = ARGV[0]+"WunderListProjects.md"
exportFile = File.new(extractPath,"w")

#extraction logic
# locate wunderlist database
#wunderlistDb = File.expand_path("~/Documents/Code/wunderlistExport/reference db/WKModel.sqlite")
wunderlistDb = File.expand_path("~/Library/Containers/com.wunderkinder.wunderlistdesktop/Data/Library/Application Support/Wunderlist/WKModel.sqlite")
projectIntMap = Hash.new
hashIterator = Array.new

i = 0
k = 0

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

		exportFile << "\n###"+projectName+":\n"
		wunderlistDatabase.execute("select ZTITLE, znote, zduedate, zcompletedat, ZTASKLIST from ZRESOURCE where ZTASKLIST=?",projectInt ) do |row|
			
			#convert date which is row[2]
			#puts row[0] 
			#puts row[1]
			task = row[0]
			note = row[1]
			dueDate = row[2]
			completedDate = row[3]
			
			if note == nil and dueDate == nil and completedDate == nil
				exportFile << "- "+task+"\n"
			else
				if dueDate!= nil and completedDate == nil
					time = Time.at(dueDate)
					year = time.year.to_i()+31
					year = year.to_s()
					time = time.month.to_s() + "/" + time.day.to_s() + "/" + year
					exportFile << "- "+task+" **"+time+"**\n"	
					#puts row[2]
				end
				if completedDate != nil
					exportFile <<  "- *"+task+"* **@done**\n"
				end
				if task != nil and note != nil and dueDate == nil and completedDate == nil
					exportFile << "- "+task+"\n"
				end
				if note != nil
					exportFile << "    - "+note+"\n"
				end
			end
		end
		k+=1
	end 

exportFile.close()	
