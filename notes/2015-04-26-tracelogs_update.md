---
tag: note
---

I've been working through various false starts and rescopes of the
TraceLogs project. The TraceLogs project is an umbrella term for a
small product around error tracking (stripped down Honeybadger/Aibrake
etc) that serves a test bed for a bunch of my ideas on software
engineering and system design. Here is a quick list of some high level
points:

* Implementation agnostic test suite
* Simlutation testing
* Benchmark suite
* As many languages & architecetures as possible
* Continuous delivery with Mesos
* Deployment pipelines with Mesos

Mostly, I want this project to level up my skills as developer in many
different areas. Secondly, the product itself should be useful. I have
written about some of these ideas in previous field notes as well. So
without any more blathering, time to run through the failed
experiments, why the failed, and the constant shifting scope to
finally arrive at something actionable.

## Failed Expirement 1: Verification Program

The first thing on the plate was to explore my ideas on complete
blackbox testing using an implementation agnostic test program. The
program would take the API server & frontend GUI hosts/ports as input
and run through tests to say the specific implementation is correct or
not. This proved to be quite challenging. There are two bits that
require testing: The HTTP JSON API & the Server side rendered HTML
GUI. I considered the following implementations. They were considered
because of previous experience and there was not point in trying to
introduce new tools into this part of the project because it's just
not important. E.g, they may be a very good testing tool in Python but
I'm not familiar with Python to execute effectively.

* Bats test suite with curl & some sort of XML thing for GUI testing
* Ruby with faraday for the API & capybara (w/Poltergiest) for GUI
* Node with supertest, request, and mocha
* Node with nightwatch, request, and mocha

Personally I was more interested in the bats option. This option
seemed the most appealing because it only required shell tools meaning
it was about as implementation agnositic as it gets--it doesn't even
have a _language_. Previous exprience using curl inside bats for HTTP
testing proved that bit was suffecient. It required custom helpers
(e.g. curl for status, curl for header) using the various output
format flags. That bit was all doable (as I'd done it before). There
was the matter of more complex JSON generation in the shell. This
sucks as there's not way to do it besides string creation. Shitty, but
manageable. So maybe not most developer friendly solution but
functional. The other question was what to do with the HTML bit.

This pretty much sunk this idea. There is no go way in the shell to
manage the DOM and user interactions. This is because this sort of
thing is inherently stateful and requires some daemon to issue
commands to. Also I don't think this area is quite explored. There was
some XML parsers but that only covers asserting on results, not
interacting with the DOM. So end here. This approach would be viable
if the process(es) under test were stateless and/or had better
interface than HTML.

So onto the next option. No code has been written at this point, just
investigation. I wanted to actually write something. So I decided to
investigate the various node options. I figured that the node
ecosystem probably has the best tools for working with the bullshit
that is web development. Since it's javascript there are plenty of
good libraries (e.g. request) for making HTTP requests. Mocha is a
decent enough test runner to make it all happen. I started off by
looking into supertest (as I'd used it on other projects for testing
express applications). Unfortuntately supertest seems to require an
http server object. This immediately nixed this setup because the
tests require network traffic. It's better off anyway because
supertest is _ok_. I prefer to make the requests and do my own
assertions.

I did not want to give up on node things just set so I decided to
investigate Nightwatch. The frontend lead at work told they used this
to test the web client. Figuring this was good enough for their uses
(which are entirely more sophisitcated than this experiment), I
decided to spike on it. This approach was certainly fraught with
tradeoffs. Nightwatch is one of those "take over the entire project"
project. It has its own test runner, its own code loder, its own
configuration file, and a bunch of other things that assert total
ownership over the repository. I figure this could be worth it since
it would manage all the browser things and provided a decent enough
interface for filling in test boxes, clicking things, and all that
other jazz. I could require request, use some promises to coordinate
test aginst the API then the GUI. It seemed like it would work. It's
also useful to note that API is very small (just two requests) and the
GUI is more complex so it seemed to OK to align these two tradeoffs.

Naturally I immediately ran into problems. The first step was to
simply get nightwatch running. The nightwatch docs have a demo test. I
could not this to work. I could not get the PhantomJS integration
working as it didn't support all the assertions. IIRC the assert title
function failed or something. I really wanted to use phantomJS because
it's headless, but wasn't entirely ready to give up. I tried using the
actual browsers with selenium. I couldn't get that working either.
Some of the assertions still failed. I was able to create one passing
"test" that simply opened google.com. However it did not include any
assertions. That alone was the deal breaker, but it also conflicted in
other areas. I wanted this test program to not require a ton of extra
dependencies. Even if I could get one example thing passing in
Firefox, that would require a selenium server, X server, and the
browser itself. Now I know you could use sauce labs or something
similar, but that's just way too many external dependencies for a
simple verification program. I did not even attempt to use request or
any other things with the API specifically because I could not even
get nightwatch working. So that was the end for this approach. I
briefly looked into some of the other things like Zombie.js, but
decided that this was as far as I was willing to go with node for this
bit. It's too bad really becuase the async nature works well for these
things.

So that left one option on the list: Ruby and most my most familar
tools. I knew this option would work so I wanted to evaluate it last.
Well "work" is subjective, because sure the networking works, but what
does the final product work?

## Failed Experiment 2: Test program with Capybara & Friends

Armed with the comforting knowledge that my chosen tools would work
with networked process, I set out to write a ruby program that took
two arguments as input: the api sever & the gui server. The test
program would executed like this: `$ trace-logs-spec api.example.com
gui.example.com`. Using a combination of capybara & faraday the
appropriate tests would happen. I set to work and some interesting
things started to happen.

First off, I wanted each part of the spec to have a unique number. For
example: `1.4.2.1 API rejects type parameter when all whitespace`. The
test suite would run then just spit out a bunch of check marks or X's
for each line item and exit or 1. This seemed like a good idea because
each test would have a single assertion (the rest being
preconditions). I created "spec" classes. Each class had an `execute`
method that took the faraday connection & capybara session as
arguments. Each class also implemented `doc.spec` and
`doc.description` to make the report nice. This went all well in good
for a few specs. I started out by writing specs for the main API call.
the specs tested things liek parameter formats and all the normal
input validation bullshit. Then two other concerns entered the
experiment.

I had a dummy implementation in ruby that existed before the start of
the experiment. I used that to test the specs. But then I asked the
question: how can I test test program? That answer is quite easy
actually. You provide a reference implementation. This in of itself is
not a problem persay, but it deos require extra work. I set out to
create the simplest possible rack applications to pass all the tests.
I mean, the absolute shittiest things. This was actually fun in some
way because I did not even use extra HTML. Just big ass heredoc
strings in the sinatra route handlers. This bit actually worked out
OK. So I soldiered on using my shitty reference implementation to
verify verificatin program.

Then the next thing happened. I had written a simple test runner. The
test runner went something like this: `$ trace-logs-spec API_URL
GUI_URL [FILE] [FILE]`, so you could do `trace-logs-spec
localhost:9091 localhost:9092 spec/api/*`. Loading the ruby file would
register the defined classes in a registry, then the test runner
iterated over each defined class, instantiated it, and called the
`execute` method (described earlier) and reported on the results. This
worked fine. The problem was writing the spec classes themselves. I
wanted to keep them isolated and small--so there was no super class or
the like. Each spec contained everything required to run it. However
this lead to a lot of copy and paste. The problem was that every API
test required an account (since it's an authenticated API). So before
making the request the spec needed to go through the sign up flow
everytime. I ended up copy and pasting this a bunch of times to keep
the experiment moving. Figuring, something will have to be done about
this eventually. The answer became obvious. Elminate the copy and
pasted by having some sort of superclass or some setup & teardown. At
that point I realized that I would just be rewriting my own test
runner (e.g. MiniTest). I was also defining the spec numbers myself.
This made it very difficult to keep them sensical beause they had to
be grouped with others (so you could see all the similar spec
numbers). That point it was just reduced to generic test class classes
where each "spec" was a method on test class. Sure there wouldn't be
nice spec numbers, but that's just the cost of doing business.

I consider this experiment a failure because no useful code was
produced and no verification program was produced. However, it did
show many ways how **not** to accomplish this task. Eventually if
fail enough you may get an idea on how to succeed.

## Moving Forward after 2 False Starts

Interesting spot that. All my experiments had failed. However the
general setup for such a verification program was now obvious:

* MiniTest
* Group related specs into files
* Provided list of tests via ARGV
* Use Faraday
* Use Capybara
* Test against reference implementation

All of those together could create a verification program. However all
the previous efforts simply glossed over a key fact in the program.
The final implementations will be asyncronous. The API returns `202
Queued` for a reason. However the reference implementation is sync
(data store directly in an imemory array). So the tests that do things
like: Make N API request, do some gui things, assert that N different
things are displayed will **not** work in general. Sure you can add a
wait, but that's just a hack. It may work sometimes but you always end
up in the scneario where _sometimes_ it takes longer so the wait time
increases, and the cycle repeats--or maybe some random thing prevented
it from working that one time. I do not want to go down this road. In
short, it is impossible to create a verification program that uses the
API & GUI in coordinate to acceptane test the final product.

I have not touched on it yet but some things pointed to needing a
third "controller" component. This thing component is like a backdoor
to be honest. This is because the two components may not provide
access to all functionality required for the tests. For example, there
are things the system admin may do but are not part of the product.
How do you access these in the product acceptance test context? This
sort of thing kept coming up, but there wasn't a need for such a thing
in these experiments, but I could see it being a requirement in more
complex systems.

Testing the machine & human interfaces at the same time also makes
things difficult. The machine interface is stateless and the GUI is
stateful. This creates cross cutting concerns and requires much
different tools. I also realized that I had no interest in _ever_
rewriting the GUI. I don't like writing GUIs. I like working with
machine to machine interfaces. For example, I want to use Erlang to
implement the product. I don't want to waste time figuring out how to
produce HTML in that language. Many languages have much better support
for creating thin clients so need to involve that in the general
experiments.

At this point I figured it was time reasses and determine how to move
forward.

## Principles of System Design

I've been refining my principles of system design more and more. One
of them is:

> optimize the public interface for integration; use statically
> defined protocols for internal interfaces.

This because you have no control over the outside world and you do
have complete control over the system internals. This principle also
means internal architecture should tend towards SOA wich each
component having a statically defined interface to optimize cross
language access. In short this boils down to use HTTP & JSON for
internet facing things & use Thrift to define internal protocols.
There is much more to say about this principle, so back to this
projects.

The best way to architect this product is to have three intefaces:

1. Internet facing HTTP & JSON API
1. Iternal facing thrift server
1. Internet facing GUI talking thrift to backend.

The thrift protocol defines everything the GUI needs and some extra
things. E.g. there is a `createAccount` RPC. This means the test
program can use a machine/machine interface instead of going through a
GUI layer. Also the frontend can be isolated and easily tested in all
casses: simply provide a mock/stub for that required thrift RPCs. The
verification program now shifts to verifying the two machine/machine
interfaces: HTTP & Thrift. This also ensures an alternate backend
implementation passes the tests so the GUI can simply be plugged in
top allow the two to evolve in complete isolation. It also allows more
complicated tests of the frontend (multiple browsers etc), but I don't
care about such things. Also working with human facing things is much
more complicated thatn working with machines and require totally
different work flows. I'm interested in things you can test and
testing look & feel is impossible. Thrift itself is also great because
it supports the large majority of langauges (and thusly covers all the
languages and architectures I'd like to evaluate).

So now that some of the key problems and scoping things are addressed,
it should be possible to move on with experiment three: implementation
agnostic HTTP API & Thrift server verification program.

## Experiment 3: Verification Program Revisted

Armed with all the lessons from previous failures and the knowledge
that the concerns are separated it was time to get going. The general
hypothesis is:

> Given a language with Thrift support & HTTP libraries and a
> reference implementation, it is possible to create an implementation
> agnostic & maintainable verification program.

This should be easy enough. I decided use D for this experiment. I
like D, it supports thrift, has built in unit testing (so testing the
reference implementation is easy enough). Also mainly because I really
like D and want to do more things with statically typed and compiled
languages. It's also nice to create an executable binary eliminating
some dependencies. Upon quick initial research D does not appear to
have a more complex test runner. This because DMD as built in
unittests so separately defined test cases with xUnit like behavior
hasn't been needed. This is not a problem because a class could be
created for each functionality or the like.

Unfortunately the D implementation seems to have failed before it even
got started. I have not been able to compile a hello world program
with the thrift libraries. Also a new version of DMD (the D compiler)
was recently released. It's uncertain if the thrift libraries will
work with the new compiler, and given the generally small D community
that any attention would be paid to such things. Compilation fails
because of a linking error for x86\_64 symbols, but it's uncertain for
_which_ library. So things have stalled there. I'm currently compiling
on OSX. I will try a linux VM (which the development should be in a
VM anyway) and see if things work. If that doesn't work without
significant time investment the D implementation should be abondoned.
This would sadden my greatly because I will probably not write any D
if cannot get it to work with these things.

There are of course alternatives to D. I would select either
JavaScript or Ruby. They are both interperted languages so things are
dependencies are pretty much the same. I _actually_ lean towards
JavaScript for this because working with thrift in Node is nicer than
Ruby and request is nicer than faraday. Mocha is decent enough as
well. Most importantly I know either Ruby or Node implementations will
work and move the experiment along. Once the verification program is
working, the real fun can begin.
