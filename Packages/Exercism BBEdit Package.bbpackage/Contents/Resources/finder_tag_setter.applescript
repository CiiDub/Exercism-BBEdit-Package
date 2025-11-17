use AppleScript version "2.4"
use scripting additions
use framework "Foundation"

-- The following functions work in macOS 10.9 and later
--
-- Origin of code: https://www.macscripter.net/t/adding-finder-tags/70025/2
-- Author: Shane Stanley

on returnTagsFor:posixPath -- get the tags
	set aURL to current application's |NSURL|'s fileURLWithPath:posixPath -- make URL
	set {theResult, theTags} to aURL's getResourceValue:(reference) forKey:(current application's NSURLTagNamesKey) |error|:(missing value)
	if theTags = missing value then return {} -- because when there are none, it returns missing value
	return theTags as list
end returnTagsFor:

on setTags:tagList forPath:posixPath -- set the tags, replacing any existing
	set aURL to current application's |NSURL|'s fileURLWithPath:posixPath -- make URL
	aURL's setResourceValue:tagList forKey:(current application's NSURLTagNamesKey) |error|:(missing value)
end setTags:forPath:

on addTags:tagList forPath:posixPath -- add to existing tags
	set aURL to current application's |NSURL|'s fileURLWithPath:posixPath -- make URL
	-- get existing tags
	set {theResult, theTags} to aURL's getResourceValue:(reference) forKey:(current application's NSURLTagNamesKey) |error|:(missing value)
	if theTags is not missing value then -- add new tags
		set tagList to (theTags as list) & tagList
		set tagList to (current application's NSOrderedSet's orderedSetWithArray:tagList)'s allObjects() -- delete any duplicates
	end if
	aURL's setResourceValue:tagList forKey:(current application's NSURLTagNamesKey) |error|:(missing value)
end addTags:forPath:

on removeTag:theTag forPath:theFile
	set currentTags to my returnTagsFor:(POSIX path of theFile)
	set newTags to {}
	repeat with aTag in currentTags
		if aTag as text ≠ theTag then set newTags to newTags & aTag
	end repeat
	my setTags:newTags forPath:(POSIX path of theFile)
end removeTag:forPath:

on run argv
	set theCmd to (item 1 of argv)
	set theTag to (item 2 of argv)
	set theFile to (item 3 of argv) as POSIX file
	my removeTag:theTag forPath:theFile -- remove tag everytime to prevent duplicates
	if theCmd = "success" then my addTags:{theTag} forPath:(POSIX path of theFile)
	-- Crude way of getting the project window to update
	-- When test results pop up it returns to BBEdit.
	tell application "Finder" to activate
	tell application "BBEdit" to activate
end run

