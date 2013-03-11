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

extractPath = ARGV[0]+"WunderListProjects.txt"
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

		exportFile << ""+projectName+": \n"
		wunderlistDatabase.execute("select ZTITLE, znote, zduedate, zcompletedat, ZTASKLIST from ZRESOURCE where ZTASKLIST=?",projectInt ) do |row|
			
			#convert date which is row[2]
			#puts row[0] 
			#puts row[1]

			if row [1] == nil
				row[1] = ""
			end

			if row[2]== nil
				row[2]= ""
			else
				row[2] = Time.at(row[2]).to_s()	
				#puts row[2]
			end
			if row[3] != nil
				row[2] = "@DONE"
			end
			
			exportFile << "        - "+row[0]+" :"+row[1]+" @"+row[2]+" \n"
		end
		k+=1
	end 

exportFile.close()	
