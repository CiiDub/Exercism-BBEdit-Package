on safari_url()
	tell window 1 of application "Safari"
		tell current tab to return URL
	end tell
end safari_url

on brave_url()
	tell window 1 of application "Brave Browser"
		tell active tab to return URL
	end tell
end brave_url

on chrome_url()
	tell window 1 of application "Google Chrome"
		tell active tab to return URL
	end tell
end chrome_url

on is_it_exercism(_url)
	try
		do shell script "echo " & (quoted form of _url) & " | grep '^https://exercism.org'"
		return true
	on error
		return false
	end try
end is_it_exercism

on get_url(browser)
	if browser = "Safari" then set _url to my safari_url()
	if browser = "Brave Browser" then set _url to my brave_url()
	if browser = "Google Chrome" then set _url to my chrome_url()
	if is_it_exercism(_url) then return _url & linefeed
end get_url

on run {}
	set browser_list to {"Safari", "Brave Browser", "Google Chrome"}
	set output_url to ""

	tell application "System Events"
		set running_apps to name of (every process where background only is false)
	end tell

	repeat with _app in running_apps
		if browser_list contains _app then
			if (count of windows of application _app) > 0 then
				set browser to (_app as string)
				set output_url to output_url & (my get_url(browser))
			end if
		end if
	end repeat
	return output_url
end run
