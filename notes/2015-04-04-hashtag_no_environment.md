---
tag: thought
---

Came across another article talking about configuring ruby programs
through dynamically generated YAML. Like what. I'm starting to really
real against this sort of shit. It made me think of a "no
environments" rule. The idea is that the program should have no
environments, but enforce operation purely through functional means.

The best I can think of is command line args. We operate in a world of
docker containers and various other traffic direct to process
scenarios. So the developer as a high level of control over how the
program is started. This makes it possible to expose every
configuration option the program requires through a CLI. This idea
should be paired with no environments. That is there is no
"production" configuration file. There is only an set of options which
are used exclusively to change the behavior of the program. This would
eliminate the need for "boot tests" as I call them.

Consider a program that uses redis. It requires a connection via a URI
prameter. Start the program with: `bin/server
--redis-uri=redis://82.382.3891.91:6397`. There no need for
environment variables. The program should abort if all required
options are not given. Environment variables are still useful, but no
to the program itself. The `--redis-uri` value could default to
`$REDIS_URL`. This way the flag may not have be provided, but the
program itself will also have explicit configuration. Such a setup
also makes it easier to see exactly what a program needs to start.
Simply run `bin/server --help`. This will tell you everything you need
to know to operate the program.

I think I will prepare some more ideas on this. Maybe blog post it.
