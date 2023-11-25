# `mdhost`

Runs `eshost`, displays the table output in the terminal, and generates a
Markdown table of a few of the results (JavaScriptCore, SpiderMonkey, and V8),
copying it to your clipboard.

## Installation

Install via [RubyGems](https://rubygems.org/gems/mdhost):

```sh
gem install mdhost
```

## Usage

### Single input

Given a single input, `mdhost` will output the table from `eshost -t` to your
terminal, and will copy to your clipboard a markdown code block containing the
relevant `eshost` command, followed by a markdown table of the results. For
example, running this:

```sh
mdhost 'Date.parse("0")'
```

Will output the following markdown to your clipboard:

```
> eshost -te 'Date.parse("0")'
```
|Engine        |Result         |
|--------------|---------------|
|JavaScriptCore|-62167219200000|
|SpiderMonkey  |NaN            |
|V8            |946710000000   |

### Multiple inputs

You can have multiple unrelated inputs at once, and a more complex table will
be generated. For example, running this:

```sh
mdhost '"hello"' "42"
```

Will output the following markdown to your clipboard:

|Input|JavaScriptCore|SpiderMonkey|V8
|---|---|---|---
|`"hello"`|hello|hello|hello
|`42`|42|42|42

### Format inputs

If you have multiple similar inputs, for example arguments to a function, you
can format them into a string passed into the `--format` or `-f` parameter. The
substring `#{}` in the format string will be replaced by each of the multiple
arguments that follow and arranged into a table. For example, running this:

```sh
mdhost -f 'Date.parse("#{}")' "1970-01-01" "Thu 1970-01-01" "Thu Jan.01.1970"
```

Will output the following markdown to your clipboard:

|Input|JavaScriptCore|SpiderMonkey|V8
|---|---|---|---
|`Date.parse("1970-01-01")`|0|0|0
|`Date.parse("Thu 1970-01-01")`|NaN|25200000|25200000
|`Date.parse("Thu Jan.01.1970")`|NaN|25200000|25200000

You can also use the `--table-format` or `-t` parameter to specify a different
format string for the "Input" column of the table. For example, if you wanted
the inputs to the function in the previous example to simply be displayed
surrounded by quotation marks, you could run:

```sh
mdhost -f 'Date.parse("#{}")' -t '"#{}"' "1970-01-01" "Thu 1970-01-01" "Thu Jan.01.1970"
Date.parse("1970-01-01")
```

And the following markdown would be output to your clipboard:

|Input|JavaScriptCore|SpiderMonkey|V8
|---|---|---|---
|`"1970-01-01"`|0|0|0
|`"Thu 1970-01-01"`|NaN|25200000|25200000
|`"Thu Jan.01.1970"`|NaN|25200000|25200000
