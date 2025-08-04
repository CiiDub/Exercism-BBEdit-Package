# Exercism BBEdit Package

[BBEdit](https://www.barebones.com/products/bbedit/) is a stalwart commercial text editor for the Macintosh computer.

[Exercism](https://exercism.org) is a non-profit, community driven, site for learning programming. They have tracks for 71 languages last I checked. You can use just their website with a built-in text editor or edit the files locally with the help of their command line tools.

This is a package to intrigate BBEdit with the Exercism website and command line tool.

## Requirements

- BBEdit, I’ve only test this on version 15.x.x but I suspect older versions will work as well.

- The Exercism [command line tools](https://exercism.org/docs/using/solving-exercises/working-locally), as of version 3.4.1.

- Ruby 2.7.4 and up.

- I developed this on MacOS Sonoma (14.x.x) and Sequoia (15.x.x).

## Installation
1. Clone project where you like to keep projects.
	
	```
	$ cd ~/projects
	$ git clone git@github.com:CiiDub/Exercism-BBEdit-Package.git'
	```
1. In your terminal navigate to the project and run the install rake command.

	```
	$ cd Exercism-BBEdit-Package
	$ rake install
	```

This will create a BBEdit package in `'~/Library/Application Support/BBEdit/Packages'`, after which the five commands will be available under the submenu __Exercism__ in the script menu. You might need to restart BBEdit.

> __✍︎ A Note About ZSH and Rake__

> ZSH's globing behavior messes with Rake's bracket syntax for receiving arguments. I recommend adding this alias to your `.zprofile` or `.zshrc` file.
>
> ```
> alias rake="noglob rake"
> ```

> You might also set the `NOMATCH` zsh option as the folks at Thoughbots did,
[How To Use Arguments In a Rake Task](https://thoughtbot.com/blog/how-to-use-arguments-in-a-rake-task). Otherwise you will have to wrap all of rakes command arguments in quotes or escape globbing characters. This doesn’t effect the installation of the package but does effect the configuration commands.

> __Little more about ZSH expansion, globbing and rake arguments__

> [4 Ways to Pass Arguments to a Rake Task](https://www.seancdavis.com/posts/4-ways-to-pass-arguments-to-a-rake-task/)

> [ZSH Globbing as an Alternative to Find Command](https://dmitry-antonyuk.medium.com/zsh-globbing-as-an-alternative-to-find-command-2ebf9da5cffe)

> [A Guide to Zsh Expansion with Examples](https://thevaluable.dev/zsh-expansion-guide-example/)


## Usage

## Configuration

