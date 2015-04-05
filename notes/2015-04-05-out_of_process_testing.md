---
tag: thought
---

Discussed current ideas on testing with Peter. We discussed the "no
environment" mantra as well. It will be interesting to see if anything
comes from that. The large part of the conversation focused on "out of
process" testing. This is a term I coined (althought I'm sure someone
has already came up with one) for creating an implementation agnostic
test suite for networked programs. E.g. If the program is a server,
then it's possible to write a client to verify the server's behavior.
This mode is entirely black box. The client has no idea what the
server is, just how to talk to it. Contract this with various forms of
testing in process. Everything that happens inside the process is some
form of whitebox testing. That is, you are aware of the internals and
can directly manipulate memory or use the programs internal
interfaces. The real world would example is starting an HTTP server
and running `curl` vs executing a test to a Rack/Plug (or similar)
interface. The ruby community exclusively does the latter. I think the
former should be investigated and applied to appropriate projects.

However there are a few concerns. Here are few:

* test suite coordination, bats + make would probably do well enough
* CLI tool availablity. Testing HTTP responses with curl and jq would
	work fine enough, but there doesn't seem to be a nice XML/xpath
	program. Seem the story for testing HTML is unclear. Note, that it
	may be possible to consider something like nightwatch.
* State management. The point of this approach is to only verifiy
	networked programs through the networked interface. However all
	prorgams need certain state/date. So as part of the test suite,
	you'll need to setup state. There may not be a way to set it up
	through the public interface. So how can you bridge that gap?
* Bang for the bug. This approach does not eliminate white-box in
	process unit tests. Instead it shifts the burden to another program
	to verify high level flow through the network interface. It does not
	make sense to test everything in this way. Whatever test cases are
	constructed should hit as much of the system as possible.
* Bats itself may not fit the use case. The key problem is that bats
	cannot provide assertion messages. It may make sense to write each
	test as an isolated bash script. There you can echo, fail, and
	source whatever other functions you need.

I'm considering this approach for tracelogs:

* Create implementation agnostic test client for the HTTP & JSON
	backend
* Some sort of javascipt thing for testing the web frontend (this bit
	assumes the backend & frontend are two distinct components)

This allows me to experiment with different backend implementations
(which is one tracelog's primary goals).
