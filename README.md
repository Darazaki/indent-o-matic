# indent-o-matic

Dumb automatic fast indentation detection for Neovim written in Lua

## How it works

Instead of trying to be smart about detecting an indentation using statistics,
it will find the first thing that looks like a standard indentation (tab or 8/4/2 spaces)
and assume that's what the file's indentation is

This has the advantage of being fast and very often correct while being simple enough
that most people will understand what it will do predictably

## Requirements

- Neovim >= 4.4

## Installation

Can be installed though any standard Vim package manager, no additional configuration required

## Contributing

I've made this little plugin as a fun side-project to learn how Lua works with Neovim
as a beginner so, if you've an idea, feel free to write a PR to improve this project!

The only rules to follow are:

- The detection algorithm should stay dumb
- The plugin itself should work with Lua & Vim code only
- Requirements shouldn't be restricted
- Break the rules within reason

Note: Forking or taking part of the code without asking is also a-ok, this it libre
MIT-licensed stuff!
