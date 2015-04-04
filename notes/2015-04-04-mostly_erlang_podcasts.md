---
tag: podcast
---

Listened two very good espidoes from the Mostly Erlang podcast. Seem
to be bunch of smart guys discussing, well, mostly erlang. First I
listened to an [episode][7langs episode] on the "7 More Languages in 7
Weeks" book. The episode itself was interesting, mostly to hear well
educated people speaking on many different languages. The episode
featured discussion on Idris. Idris is a language is dependent types.
This is crudely summarised as language contains a programming language
inside the system. The author of the book mention that Idris changed
the way he fundamentally thought about programming. Whenever someone
says that, it grabs my attention. So luckily a few episodes later on
they did one on [Idris][idris episode] with the creator of the
language.

This episode was much more interesting. It definitely wet my whistle.
This topic requires more research. The Idris project itself seems to
be portable and powerful. Notably is has an intermediate form. The
intermediate form is something like "first functional form" (cannot
remember the exact name). It made me think of a bunch of composed
functions that could be executed in any language that can invoke
functions (read: all of them). Idris has a compiler for Javascript and
for C (which then generates native code). All in all very interesting.
Key take away from the language creator:

> Idris is a project for building DSL

This quote is paraphrased, but the creator kept hammering this point
that the dependent types should make it easier to express the problem
domain in a statically verifiable way.

[idris episode]: http://mostlyerlang.com/2015/03/31/061-idris/
[7langs episode]: http://mostlyerlang.com/2015/02/03/more-languages/
