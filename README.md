# Redrum

![](https://raw.github.com/shayneholmes/i/master/redrum.png)

# Introduction

A novelty plugin that uses vim's `conceal` feature to show a buffer as if all
its non-whitespace characters were repetitions of the iconic phrase "All work
and no play makes Jack a dull boy" from "The Shining".

It is obviously of little utility.

Try inserting in a document with this plugin enabled: The experience of typing
out your own words, only to see them come out as if you're Jack Nicholson (or
Jack Torrance), is disorienting and mildly entertaining.

Note: This plugin doesn't actually change any buffer's contents, merely how
they're shown.

## Usage

### `:Redrum`

  Toggle redrum on and off.

### `:Redrum!`

  Turn redrum off.

## Options

Options don't immediately take effect: If you change an option while redrum is
on, you'll need to turn redrum off and on again to see any change.

Options can be configured for an individual buffer by prefixing them with `b:`
instead of `g:`.

### `g:redrum_message`

  - Type: `String`
  - Default: `'All work and no play makes Jack a dull boy. '`

  This is the message that will repeat over and over again, in the shape of
  your text.

## Inspirations

 * vim-veil: https://github.com/swordguin/vim-veil/
