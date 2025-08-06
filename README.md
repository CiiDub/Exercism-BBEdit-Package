# Exercism BBEdit Package

[BBEdit](https://www.barebones.com/products/bbedit/) is a stalwart commercial text editor for the Macintosh computer.

[Exercism](https://exercism.org) is a non-profit, community driven, site for learning programming. They have tracks for 71 languages last I checked. Every track provide a wealth of exercises *-a.k.a. lessons-* for you to learn that language. You can use just their website with a built-in text editor or edit the files locally with the help of their command line tools.

This is a package to intrigate BBEdit with the Exercism website and command line tool.

## Requirements

- BBEdit, I’ve only test this on version 15.x.x but I suspect older versions will work as well.

- The Exercism [command line tools](https://exercism.org/docs/using/solving-exercises/working-locally), as of version 3.4.1.

- Ruby 2.7.4 and up.

- I developed this on MacOS Sonoma (14.x.x) and Sequoia (15.x.x).

## Installation
1. Clone the project where you like to keep projects.
	
	```
	$ cd ~/projects
	$ git clone git@github.com:CiiDub/Exercism-BBEdit-Package.git'
	```
1. Navigate to the project and run the install rake command.

	```
	$ cd Exercism-BBEdit-Package
	$ rake install
	```

This will create a BBEdit package in `'~/Library/Application Support/BBEdit/Packages'`, after which it’s commands will be available under the submenu `Exercism` in the script menu. You might need to restart BBEdit.

>__☰ Commands as They Should be Displayed__
>
>``` 
> ⎚ Open Exercise in Browser
> 
> ---
> ⇣✍ Download Exercise with Clipboard
> 
> ⇣⎙ Download Exercise with Browser
> 
> ---
> 
> ⚖︎ Test This Exercise
> 
> ⇡✌︎ Submit This Exercise
> ```

You may use `rake unistall` to remove this package, no harm done.

## Usage
__To Begin With__

1. Sign up for an account at [Exercism](https://exercism.org). Become familiar with the website and how it works. You might want to do a couple of the exercises online before working locally.

1. Install their CLI tool. You can find instructions here: [Working locally with the Exercism CLI](https://exercism.org/docs/using/solving-exercises/working-locally).

1. Navigate to a track and exercise that you are interested in work on.

__The Commands__

- ⎚ Open Exercise in Browser

	With an exercise opened in BBEdit you can use this command to *open* that exercises page in your default browser.

- ⇣✍ Download Exercise with Clipboard

	Every exercise have *WORK LOCALLY (VIA CLI)* and *Start in editor* sections that provides a CLI command to copy.
	
	> __✍︎ For Example__
	>  
	>  ```
	>  exercism download --track=elixir --exercise=freelancer-rates
	>  ```
	
	You can then paste it into your terminal to run the command and download the exercise to work on locally.
	
	Use this command in lieu of step two. It will download and open the exercise in BBEdit using the copied command.
	
- ⇣⎙ Download Exercise with Browser
	
	This does the same thing as above but you don’t have to copy anything. I works with Safari, Chrome, and Brave. 
	
	> __✍︎ Browser Support__
	> : Adding support for any browser with and AppleScript library should be simple, so I believe that included any Chromium browser.
	> Firefox does not provide proper AppleScript support. I had implimented a Firefox *handler* using interface scripting. This was really hacky and created edge cases where the command would fail. So I pulled it out. After all, the *Download Exercise with Clipboard* works fine.
	
	>__✍︎ Download Safety__
	> : If you’ve previously downloaded the exercise in question both download commands will provide you with options to just open the exercise or to overwrite it if you want a clean slate.
	
- ⚖︎ Test This Exercise
	
	This will run an exercises’ test and present the results. I try to display the result in a BBEdit kind of way, as an open log file. I’m imitating the behavior of the `Run` command from the shebang `#!` menu.
	
	> __✍︎ Key Customization__
	> : `#! > Run` has a key command set to `⌘R` by defualt in BBEdit. I set `⌃R` to envoke this command. The easiest way to do this is with BBEdit's Script Pallete.

- ⇡✌︎ Submit This Exercise
	
	This will submit your solution and open the exercises’ page for you.
	
## Configuration

@

@

@

> __✍︎ About ZSH and Rake__
>
> ZSH's globing behavior messes with Rake's bracket syntax for receiving arguments. I recommend adding this alias to your `.zprofile` or `.zshrc` file.
>
> ```
> alias rake="noglob rake"
> ```
>
> You might also set the `NOMATCH` zsh option as the folks at [Thoughbots](https://thoughtbot.com/blog/how-to-use-arguments-in-a-rake-task) did. Otherwise you will have to wrap all of rakes command arguments in quotes or escape globbing characters. This doesn’t effect the installation of the package but does effect the configuration commands.
>
> __Little more about ZSH expansion, globbing and rake arguments__
>
> [4 Ways to Pass Arguments to a Rake Task](https://www.seancdavis.com/posts/4-ways-to-pass-arguments-to-a-rake-task/)
>
> [ZSH Globbing as an Alternative to Find Command](https://dmitry-antonyuk.medium.com/zsh-globbing-as-an-alternative-to-find-command-2ebf9da5cffe)
>
> [A Guide to ZSH Expansion with Examples](https://thevaluable.dev/zsh-expansion-guide-example/)
