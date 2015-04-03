# Field Notes Microbloggy Application

![Field Notes][http://ecx.images-amazon.com/images/I/61ChcbV2nbL._SY355_.jpg]

This repo contains a simple ruby web application for displaying "field
notes". Its designed to be a companion during your day to day work to
record and catalogue different thoughts on resources.

## Testing

	$ make test

## Production

	$ bin/server -p $PORT

## Developing

	$ script/dev-server

## Writing Notes

The application is vaguely inspired by [Jekyll][] without out all the
fancy case handling. Each note is a single markdown file. The file
name should match the format `YYYY-MM-DD-anything_else.md`. Inside the
file set the tag via YMAL frontmatter. Here's an example:

	---
	tag: article
	---

	I read this awesome [article](http://example.com) and it tought me
	so much!

The code will match the dates (via the `YYY-MM-DD`) and the
appropriate `tag` to create a nice monthly view grouped by tag. The
content is parsed with [redcarpet][] with useful extensions enabled.

## Taking Notes

The field notebook is supposed to be by yourside whenever you need it.
Most work is done at a computer these days. So we have the technology
to create a simple script that can live with us in the shell. This
will make it easy to jot down notes in the editor--especially useful
if you spend the whole day in the terminal. There is an example in
[script/fn](script/fn). I've only tested in OSX (which uses BSD
commands) so GNU folks may need to update it. Once setup you'll get
something like this:

	$ fn type as many things as you want here
	$ ... now write what in EDITOR ...

The "type as many things as you want here" is sanitized and joined
with a properly formatted date and put into the property directory.
Next just commit the changes and push how you like.

[redcarpet]: https://github.com/vmg/redcarpet
[jekyll]: http://jekyllrb.com
