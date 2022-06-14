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

Can be installed through any standard Vim package manager, configuration is optional

## Configuration

Configuration is done in Lua:

```lua
require('indent-o-matic').setup {
    -- The values indicated here are the defaults

    -- Number of lines without indentation before giving up (use -1 for infinite)
    max_lines = 2048,

    -- Space indentations that should be detected
    standard_widths = { 2, 4, 8 },

    -- Skip multi-line comments and strings (more accurate detection but less performant)
    skip_multiline = true,
}
```

You can also directly configure it from a Vim file by using the `lua` instruction:

```vim
lua <<EOF
require('indent-o-matic').setup {
    -- ...
}
EOF
```

Optionally you can define language-specific settings using the `filetype_$ft` tables:

```lua
require('indent-o-matic').setup {
    -- Global settings (optional, used as fallback)
    max_lines = 2048,
    standard_widths = { 2, 4, 8 },

    -- Disable indent-o-matic for LISP files
    filetype_lisp = {
        max_lines = 0,
    },

    -- Only detect 4 spaces and tabs for Rust files
    filetype_rust = {
        standard_widths = { 4 },
    },

    -- Don't detect 8 spaces indentations inside files without a filetype
    filetype_ = {
        standard_widths = { 2, 4 },
    },
}
```

If a preference hasn't been set in the language-specific settings, it'll be retrieved
from the global settings

`:IndentOMatic` is also made available to detect the current buffer's indentation
on demand

## Alternatives

- [guess-indent.nvim](https://github.com/NMAC427/guess-indent.nvim) by Nicolas Camenisch: Smarter algorithm, configuration similar to indent-o-matic (see [explanations/benchmarks](https://github.com/Darazaki/indent-o-matic/issues/12))
- [crazy8.nvim](https://github.com/zsugabubus/crazy8.nvim) by zsugabubus: Smarter algorithm
- [DetectIndent](https://github.com/ciaranm/detectindent) by Ciaran McCreesh: Manually ran, smarter algorithm, Vim compatible
- [vim-sleuth](https://github.com/tpope/vim-sleuth) by Tim Pope: Even smarter, Vim compatible

## Contributing

I've made this little plugin as a fun side-project to learn how Lua works with Neovim
as a beginner so, if you've an idea, feel free to write a PR to improve this project!

The only rules to follow are:

- PRs should go to the `testing` branch (for, well, testing if everything still works)
- The detection algorithm should stay dumb
- The plugin itself should work with Lua & Vim code only
- No configuration required
- System requirements shouldn't be restricted
- Break the rules within reason

Note: Forking or taking part of the code without asking is also a-ok, this is libre
MIT-licensed stuff!
