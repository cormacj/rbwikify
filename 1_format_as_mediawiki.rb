#Written by Cormac McGaughey, 2018
#This script reformats the interrupts list from http://www.cs.cmu.edu/~ralf/files.html for mediawiki
#This makes it one huge file... I ran COMBINE.COM in dosbox to make INTERRUP.LST
#
#This then reformats the categories, and SeeAlso: parts for cross referencing.
#
#Why? Well I needed to go look up some things on old code I was patching to work inside dosbox.

#First, make a hash of all the categories from CATEGORY.KEY - I added a - category so that entries that
#didn't have a category get one anyway
category = Hash.new("category")
category = {
        "A" => "applications",
        "a" => "access software;screen readers",
        "B" => "BIOS;Basic In/Out System (BIOS);In/Out system (BIOS);Out/In system (BIOS)",
        "b" => "vendor-specific BIOS;BIOS (vendor-specific);extensions (BIOS)",
        "C" => "CPU-generated",
        "c" => "caches;spoolers",
        "D" => "DOS kernel;kernel (DOS);operating system (DOS)",
        "d" => "disk I/O enhancements;enhancements (disk I/O)",
        "E" => "DOS extenders;extenders (DOS)",
        "e" => "electronic mail;e-mail;mail (electronic)",
        "F" => "FAX;telefax",
        "f" => "file manipulation",
        "G" => "debuggers;debugging tools",
        "g" => "games",
        "H" => "hardware",
        "h" => "vendor-specific hardware;hardware (vendor-specific)",
        "I" => "IBM workstation;IBM terminal emulators",
        "i" => "system info;system monitoring",
        "J" => "Japanese",
        "j" => "joke programs",
        "K" => "keyboard enhancers;enhancers (keyboard)",
        "k" => "file compression;compression (files)",
        "l" => "shells;command interpreters",
        "M" => "mouse;pointing device",
        "m" => "memory management",
        "N" => "network",
        "n" => "non-traditional input devices;special input devices",
        "O" => "other operating systems;non-standard operating systems;operating systems (non-standard)",
        "P" => "printer enhancements;enhancements (printer)",
        "p" => "power management",
        "Q" => "DESQview programs;TopView programs;Quarterdeck programs",
        "R" => "remote control;remote file access",
        "r" => "runtime support",
        "S" => "serial I/O;COM port I/O",
        "s" => "sound;speech",
        "T" => "DOS-based task switchers;task switchers;multitaskers",
        "t" => "TSR libraries",
        "U" => "resident utilities;utilities (resident);TSR utilities",
        "u" => "emulators",
        "V" => "video",
        "v" => "virus;antivirus",
        "W" => "MS Windows;Windows",
        "X" => "expansion bus BIOSes;BIOSes (expansion bus)",
        "y" => "security",
        "*" => "reserved",
	"-" => "undefined"
		}

#This function splits off things like INT 03"CPU" and formats it to [[INT 03]]"CPU"
#It makes allowances for categories where it doesn't have the quotes.
def cleanprint(arg)
	static=arg
	#print "------\nProcessing #{static}\n"
	retval=""
	quote=static.split('"')
	if quote[1]!=nil
		if "OPCODE "==quote[0] #the split includes the space
			retval="[[#{quote[0]}\"#{quote[1]}\"]]"
		else
			retval="[[#{quote[0]}]]\"#{quote[1]}\""
		end
	else
		retval="[[#{static}]]"
	end
	#print "Ended with #{retval}\n-------\n"
	return retval
end

#Start grabbing the data
File.readlines('INTERRUP.LST').each do |line|

#check for --------
ah=""
ax=""
secondreg=""
secondreg_value=""

if line.start_with?('--------')
	#print "Category line #{line}"
	catletter=line[8] #get category letter
	interrupt=line[10,2]
	if catletter!="!"
		print "[[Category:#{category[catletter]}]]\n"
		if "--"==line[14,2] then
			ah=line[12,2]
			reg="AH=#{ah}h"
			if ah=="--" then 
				reg=""
			end
		else
			ax=line[12,4]
			reg="AX=#{ax}h"
			if reg.start_with?('AX=--') #Work around for wierdness where AL is used rather than AH
				reg="AL=#{reg[5,2]}h"
			end
		end
		if "--"!=line[16,2]
			secondreg_value=line[18,4].tr("-","")
			secondreg="#{line[16,2]}=#{secondreg_value}h"
		end
		#print line
		$ginterrupt=interrupt
		print "== INT #{$ginterrupt}"
		if reg!="" then
			print "/#{reg}"
		end
		if secondreg!="" then 
			print "/#{secondreg}"
		end
		print " ==\n"
	end
	line="" #Processed, blank it
end
	if line.start_with?('SeeAlso:')
		#print "Processing: #{line}\n"
		print "See Also: "
		links=line.chomp.split("SeeAlso: ")[1] #Clean Off the SeeAlso part
		link_reference=links.split(',') #Split the comma delimited list
		link_reference.each do |refs_link|
			if refs_link.start_with?('INT')
				print cleanprint(refs_link)
				if refs_link!=link_reference.last
					print ", "
				end
			elsif refs_link.start_with?('OPCODE') #Format for OPCODE "AAD" style seealsos
                                print cleanprint(refs_link)
                                if refs_link!=link_reference.last
                                        print ", "
                                end
			else
				print cleanprint("INT #{$ginterrupt}/#{refs_link}")
                                if refs_link!=link_reference.last
                                        print ", "
                                end
			end
		end
		print "\n"
		line="" #Processed, blank it
	end
	print line #If its not processed, print it
end
