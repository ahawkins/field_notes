---
tag: article
---

Came across this good paper on [software architecture patterns][link].
The paper is a short read, it's ~40 pages. The paper isn't ground
breaking but it does cover a few patterns at the high level. One quote
did stick with me though:

> If you find you need to orchestrate your service components from
> within the user interface or API layer of the application, then
> chan‐ ces are your service components are too fine-grained.
> Similarly, if you find you need to perform inter-service
> communication between service components to process a single
> request, chances are your service components are either too
> fine-grained or they are not parti‐ tioned correctly from a business
> functionality standpoint.

This made me the consider the architecture at saltside. I've never
considered it a microservice architecture. It's always been "lagom"
SOA. This did make me consider moving the search service into the core
service. Originally it was separated for development purpose and not
for true architectual reasons. I figured it was better to have an
isolated codebase people could work on without getting wrapped up into
the development concerns of another.

A good rule for defining the boundaries between services is how much
cross talk there could be. In the core service case it has to push
notification to search for indexing and removing data. Since core is
the primary data owner it makes sense to move that functionality
inside core. Not sure if that makes sense, but the paragraph did make
me consider it.

[link]: http://www.oreilly.com/programming/free/files/software-architecture-patterns.pdf
