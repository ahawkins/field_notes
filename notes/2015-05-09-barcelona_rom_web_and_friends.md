---
tag: design
---

I stat down to write a _very_ thin HTTP abstraction after talking with
Piotr on design and Thrift influences. After a few hours [barcelona][]
was born. I don't know how to _really_ describe it so I call it an
HTTP <-> object mapper. It wires path names to method calls with
encapsulated HTTP semantics. Sure I had created it, but I hadn't used
for anything. I considered using it for the Tracelogs experiment but I
don't see continuing that effort in Ruby. Luckily Piotr and I came up
with an idea that proved be a useful test bed. It's a simple ruby
application built the new way (tm).

This is my structure for creating ruby web applications:

* Barcelona for mapping HTTP to my object(s)
* ROM for persistence
* Mustache for views
* No environments!
* Write all executables yourself (Take back ARGV!)

I had an idea of how these things could fit together but I wasn't
quite sure. I started out using Cucumber features to specify the
application's behavior (because that's all I could reason about) and
used that to drive out object design and collaboration. It started a
bit shaky at first, but as I wrote more code things got better. It
turns out this arrangement is pretty damn nice!

This was the first time in years that I done any web development
outside of a larger framework so that was interesting. This was also
the first time using mustache without any integrations. It was _much_
nicer this way! It also tears down some barriers since it's obvious
how a view class turns into HTML. I was also able to solve the
annoying layout problem using simple OOP. Templates are one the
biggest bullshit things about web development so it's nice that I
could solve this problem in a clean way. I'm absolutely confident this
layer will scale without problems while maintaining transparency (much
more so than I felt inside Sinatra).

I'm also quite happy writing my own executables; now I'm back in
control of how my code is loaded and how various blocking foreground
things (like servers) are configured and started. Most importantly
there is no `rackup` bullshit! Feels great. All the options that could
ever be are exposed as options flags and the appropriate thing
happens. Want to reload code before each request? Use `--reload`. Need
some junk data? Provide `--dummy-data`. Most importantly it gives me a
single place to collect all the object wiring that has to happen.

There are a few things I'm still on the fence about--they're mostly
barcelona concerns (so not specific to this codebase). Barcelona needs
a route generator. This is the only way to say on the same side of the
abstraction. Right now the processor object has no clue what HTTP
route is, but naturally you need to create them in templates. So that
must be addressed.

I'm also curious about removing inner presenter classes from the view
classes and extracting those as entities. ROM can map relations to
different classes so such a thing _may_ be possible, but I'm unsure of
how this would come out in practice. It probably makes more sense for
data heavy models and not objects requiring a bunch of view decoration
(e.g. timestamp formatting). I'm mostly on the fence about this one
because Piotr leans this way but I don't really see problem with
creating a bunch of `DelegateClass` to handle all view specific
presentation. I bet this is highly problem domain dependant not a
general case thing.

Then there's the global configuration object. I'm most curious how to
construct the system where such an object is not possible. I mentioned
wiring objects together. This is a natural thing when there's
collaborating classes. The program **must** take
`--data-store=sqlite://tmp/db.sqlite3` and turn that into an object.
Then in turn other objects in the system will need that object. I
ended up with a constant called `SYSTEM` that collects all these
objects. It's a simple class instance with some extra methods tacked
on. In practice I find that this object is not needed inside
application code. It's only needed in tests. I think that's because
test code is different than the general path (in some ways). I don't
know if the existence of such a constant is good or bad thing but
right now this is the only way I can construct these programs.

Regardless of it's implementation the existence of the class has
proven vary useful! The `System` class has methods for everything the
system can do. There's not need to coordinate use cases across
multiple objects. This means there's only one way to do things and the
outcome is the same every time. This has proven most useful in tests.
For example the system has a `clear` method. That method will clear
all things that need to be cleared (like a background queue, data
store, or any thing _else_). All in all I'm quite happy with this
facade object.

All in all the result of this experiment is promising. It's shown
enough promise to continue in this direction. I'm also starting to
consider how to expose HTTP semantics through `Barcelona::Request` and
`Barcelona::Response`. Things like sessions, files, and various other
information is much cleaner like this than with rack itself. So good
things coming for future ruby web work!

[barcelona]: https://github.com/ahawkins/barcelona
