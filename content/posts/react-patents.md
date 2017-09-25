---
title: React and Patents
date: 2017-09-25
published: false
---

Over the past several weeks there has been an evolving discussion about the
licensing of [React](https://facebook.github.io/react/), a popular library for
building complex user interfaces. There has been a lot of conflicting information
posted about the state of React, what kind of licensing terms are involved, and
why all of this matters. I would like to try and set the record straight to the
best of my ability. But first:

# A Disclaimer

I am not a lawyer and nothing in this post should be considered legal advice.
If you have any specific questions about any of this, please talk to a licensed
intellectual property attorney in your local jurisdiction. This is for
entertainment purposes only. This is also just my opinions/knowledge, not those
of my employer, Facebook, the Apache Software Foundation, or anyone else.

Okay, with the disclaimer out of the way, let's rewind, where did all this start?

## The Story Up Until Now

While we could start way back with the initial creation of React, that was a
long time ago and the part of the story we all care about begins in April 2017.
In a somewhat unassuming Jira ticket, [one of the Cassandra team asked the Apache
Software Foundation legal affairs team if directly integrating with RocksDB was
acceptable](https://issues.apache.org/jira/browse/LEGAL-303). I hear you say
"RocksDB? I thought this was about React!" well that was brought up soon after
in the same ticket, as both RocksDB and React were made available under the same
license. This was resolved a few months later in July when the ASF legal team
made the call that the license terms used for RocksDB (and therefore React) were
incompatible with the requirements on ASF projects. This was quickly picked up
by the media and run with headlines like ["Apache says 'no' to Facebook code
libraries"](https://www.theregister.co.uk/2017/07/17/apache_says_no_to_facebook_code_libraries/).

We'll come back to RocksDB later, but with React this kicked off a firestorm of
concerned and confused users asking what was going on. There was some discussion
for a few weeks as to [if React should be changed to a different license](https://github.com/facebook/react/issues/10191), but
in mid-August this was closed with Facebook [confirming that they felt the current
license was appropriate](https://code.facebook.com/posts/112130496157735/explaining-react-s-license/).

Then, unexpectedly, a few days ago (September 22nd) Facebook announced they would
be [relicensing React and several related projects](https://code.facebook.com/posts/300798627056246/relicensing-react-jest-flow-and-immutable-js/)
to use the MIT license.

Okay, so that's the whole history, let's look at some major questions that came
out of these few months:

## Who Owns React (and RocksDB)?

To get it out of the way, code is in general owned by whomever writes it. If you
write code as a part of your job, it is owned by your employer, give or take what
is in your employment contract. Facebook does require a contributor license agreement
for their projects, and the CLA grants Facebook some strongly worded rights for
copyright use and patent rights, but in the end each contributor remains the
owner of the copyright in their contribution. This means that while React is
managed by Facebook, and they down own a lot of the copyright over their projects,
in the end they are actually owned by the collective community of developers that
works on them. In the case of RocksDB specifically there is also a large chunk
of the code which is owned by Google, as it is an outgrowth of an earlier Google
project called LevelDB.

Ownership is generally thought of in terms of copyright ownership, as that's the
more directly relevant bit, but another factor in the control of software is
who owns any patents which cover the software. We'll leave this part for later
in this post as it's a much more complex topic.

## What Was The Original License For React (and RocksDB)?

The license used originally by Facebook has two main parts, a copyright license
and a patent license. The copyright license half is pretty straightforward, a
3-Clause BSD license. This is part of a family of minimalist copyright licenses
that allow use, copying, and modification of the code. Without this license, those
rights would remain exclusively with the copyright holders (i.e. the person or
company which wrote each section of the code). The [BSD license](https://opensource.org/licenses/BSD-3-Clause) (usually in 2
or 3-clause variants, sometimes 4) is fairly well known and the requirements you
must meet to use those licensed rights (preserve the copyright notice and license,
don't use Facebook's name in endorsements, don't sue anyone because the code doesn't
work) are quite reasonable.

The second half is a patent license, which says that
anyone using the software is allowed to use any Facebook patents that might cover
that software so Facebook cannot sue them for patent infringement. The goal here
is the same as with the copyright license, making sure users have enough rights
to be successful open-source citizens while protecting Facebook and the other
rightsholders involved.

Facebook has termed this a "BSD+Patents" license, though this should not be
confused with the OSI-approved license also called "BSD+Patent" (or sometimes
BSD-2-Clause-Patent) as the two are unrelated.

## What Problem Did The ASF Have With BSD+Patents?

As mentioned in the previous section, the use of the BSD license for copyrights
was 100% okay with everyone, the issues all revolved around the patent license.
This was something created by Facebook specifically, so to start with it was not
a well-known quantity in the same way as things like the BSD or MIT license
would be. While using standardized licenses (or more specifically, licenses recognized
by the [Open Source Initiative](https://opensource.org/licenses/alphabetical))
does certainly make life easier for open-source lawyers, it isn't a specific
requirement.

The Apache Software Foundation does its best to make the projects under its
umbrella be somewhat uniform from a legal perspective. If you get a legal "okay"
to use one of them, you can almost certainly use any other ASF project. This is
important for ecosystem stability as many ASF projects depend on other ASF projects
to function. We'll get to the Apache-2.0 license in more detail later, but the
ASF created it to help in this mission, to provide a unified set of licensing terms
for all ASF projects. But the open-source ecosystem is a big place, and many
ASF projects want to depend on libraries not from the ASF and thus sometimes
under different license terms. So the doctrine used by the ASF legal team is that
other licenses are okay as long as they do not put any more requirements on the
end user than the Apache-2.0 license does. So for example, pretty much all software
in the world depends on zlib, which is distributed under the [zlib license](https://www.zlib.net/zlib_license.html),
but from the point of view of the ASF crew, that is less restrictive than
Apache-2.0 so it doesn't make life any harder for end users.

The problematic section of the patent license was under what conditions
the license would be revoked. While most copyright licenses are given as irrevocable,
it is normal for patent licenses to include a termination clause in the case of
a lawsuit over the software. This helps to protect the company, if they get sued
they can at least prevent you from continuing to benefit from their IP for the
duration of the lawsuit. But that said, the Facebook patent license [went a lot
further](https://github.com/facebook/react/blob/b8ba8c83f318b84e42933f6928f231dc0918f864/PATENTS):
"The license granted hereunder will terminate, automatically and without notice,
if you ... initiate ... any Patent Assertion against Facebook or any of its subsidiaries or corporate
affiliates". So rather than being scoped to just lawsuits over the specific
project, any patent suit brought against Facebook would terminate the patent
license. The ASF Legal team decided this represented a restriction above and
beyond the Apache-2.0 license, and so it could not be used with ASF projects.

It should be repeated that this was a decision by the ASF Legal team for ASF-controlled
projects, that's it. This was not an abstract judgment that Apache-2.0 code can't
be used with BSD+Patents in general, nor was it any comment on the quality of
Facebook's code or on their patent license as being good or bad. It was specifically
to ensure the licensing goals of the ASF remained safe, nothing more.

## So What Happened To RocksDB?

In response to the original decision from ASF Legal, the RocksDB team [quickly
switched from BSD+Patents to Apache-2.0](https://github.com/facebook/rocksdb/pull/2589).
There isn't a lot of public information on how this change went down or why, but
given it happened within a few hours I'm guessing it was considered fairly uncontroversial
by everyone involved. As mentioned earlier, there is a lot of code from LevelDB
still in use, which is owned by Google and will continue to be made available
under the terms of the 3-Clause BSD license.

One slight addendum, since this will come up again with React: I'm not actually
100% what the legal basis for the change of license was. Normally you need
approval from all copyright holders before changing a license, but it is possible
the Facebook legal team decided the sublicensing requirement of the Facebook CLA
made it okay to relicense in this fashion without getting approval. Or it's
possible they just figured everyone would be okay with it, which is probably
correct.

## Why Did Facebook Want The Broad Termination Clause?

Without getting too far in to the details, one major problem facing the software
industry right now is a plethora of patent lawsuits from companies that buy out
very broad or wide-reaching patents and then use them to try and extract settlements
from a large number of software companies by threating litigation. These are
colloquially called "patent trolls". Regardless of your personal feelings on the
issue, Facebook considers this a threat to their business and was using the broad
termination clause across all of their open-source software to try and take some
wind out of the sails of future trolls as if the troll was using anything under
the Facebook patent license, if they filed a lawsuit over one of the troll patents,
Facebook could counter-sue using one of theirs.

This defensive measure was deemed important enough to reject the initial request
for relicensing React. And speaking personally, I totally understand that impulse.
I agree that troll lawsuits are a chilling scourge on our industry and in general
I support legal defense machinery to try and reduce them.

## Why Did Other People Not Want The Broad Termination Clause?

While you might initially think "but I would never sue Facebook", things are
often more complex than that. For other large companies, this one-sided termination
clause effectively means the company as a whole is giving up the right to pursue
legitimate patent infringement cases against Facebook. Given the scope and scale
of many patent portfolios, this represents an unacceptable risk to many (already risk-averse)
legal departments.

For smaller companies, especially VC-backed startups, suing Facebook would likely
have never been an option in the first place even if Facebook was very clearly
infringing as the legal costs can be immense. However the other shoe dropping
is that many startups want to end up getting acquired by larger companies, so
all the same issues get pulled back in. While I don't know of any examples
citing React specifically, acquisition deals fall apart all the time over intellectual
property concerns so this is something even startups should take seriously.

That said, for some cases it really is okay. I personally used React for
some projects, like the dashboard that powers my home information system, when
it was under the BSD+Patents license.

## So If React Isn't BSD+Patents Anymore, What Happened?

While the public discussion about relicensing React ended after the first 4 weeks,
apparently it continued within Facebook, for which they should be recognized and
commended. This resulted in a somewhat surprising announcement that React will switch
from BSD+Patents to the MIT license. At the time of writing, I don't
think this change has been made, but they are planning to implement it soon. As
with the RocksDB license change, I'm unsure of the exact legal mechanism being
used, especially since this is moving to a less restrictive license (i.e. the
copyright holders are giving up more rights). But regardless, we can expect this
to be reality soon and the rest of this post assumes Facebook will follow through
on the license change.

## Awesome, This Means Everything Is Fine Now, Right?

Maybe. Here is where things start getting dicey. The MIT license is generally
thought of as a copyright license, just like the BSD licenses. With the switch
to it, this would mean Facebook is intending to terminate (or at least no longer
rely on) their patent license. But that doesn't make Facebook's patents go away.

A quick check on [Google Patents](https://patents.google.com/?assignee=Facebook%2c+Inc.)
shows Facebook currently controls around 5200 patents (not even counting their subsidiaries). Without going through
every single one of them, there is no good way to know which, if any, would
apply to React or related projects. The posture Facebook initially took around
their patent license certainly intimated that they think one or more of their
patents does apply, but they don't have to actually show their hand until/unless
they actually file a lawsuit against someone the first time.

So if we are now ignoring the Facebook patent license, there are three scenarios.
One is that the whole thing was a bluff (perhaps unintentionally) and there are
no Facebook patents which cover React, or equivalently Facebook thinks any
patents they do have would be indefensible in a [post-Alice](https://en.wikipedia.org/wiki/Alice_Corp._v._CLS_Bank_International)
world. Second, React will now be covered by a copyright license, but all patents
covering React (and here we assume there are some) will not be licensed and Facebook
can sue anyone using React at any time. Third, Facebook is relying on a somewhat-controversial
reading of the MIT license that says it does provide a patent license.

The first case seems unlikely. The second is downright evil and I have more trust
in both the Facebook open-source folks and the React team than that. This leaves
us with option three, further bolstered by a [tweet from one of the React team](https://twitter.com/dan_abramov/status/911508180894720000).
This reading of the MIT license revolves around the phrase "including without
limitation the rights to use". Some people claim given the broad wording of this
rights grant, it would include both copyrights and patent rights. But this is
the aforementioned dicey bit. To the best of my knowledge, an implicit patent
grant this vague and outside of a commercial context has never been tested in court.
If this is the goal of the Facebook team, it would also mean they are effectively
permanently renouncing those patents, as the implied grant would have no termination
rules, even for a lawsuit directly about React. I would very much like to believe
this case is our reality, but without a more well-known legal footing, I'm very
concerned we may have inadvertently created a scenario two where everyone is
actually just infringing all the time.

The announcement of the relicensing from Facebook was very notably absent any
discussion of patent rights, and all postings I've seen from Facebook folks about
this have been very carefully worded to avoided specifically stating what Facebook
thinks the patent rights situation will be.

## But You Said RocksDB Relicensed And Everything Was Fine?

RocksDB switched to the Apache-2.0 license. Like many newer licenses, it
includes specific provisions covering both copyright rights and patent rights
(and more). This means that patent rights around RocksDB might actually be more
restrictive than React, but they are far more explicit and well understood.

The fact that Facebook chose the MIT license for React instead of Apache-2.0
sends a signal that they may be trying to hedge their bets here in a way the
RocksDB team did not.

## Okay, Can I Just Use Preact Instead?

Again, maybe. While copyright law has a concept of "derived works" vs.
"non-derived works", patent law (in this case) does not. Preact is (I think)
built as a whitebox reimplementation of many React APIs in a way that Facebook
doesn't hold any copyright over it. But patents don't care about that, if Preact
implements an algorithm or process patented by Facebook it doesn't matter if it
was created independently or not. But since we don't know which of their
thousands of patents might apply, there is no good way to say if Preact would
be infringing or not.

## Tl;Dr What Do I Do?

At this time, I still think it would be wise for companies to avoid React. If
at some point in the future Facebook provides more specific guidance about patent
rights this could be easily remedied, but only time will tell on that. I do
firmly believe that Facebook and the React team are not being intentionally
bad actors in all this, and the open-source community should give them the
benefit of the doubt when it comes to incomplete explanations, but at the same
time we each need to ensure the legal safety of our own companies and projects.

If you found this discussion of intellectual property issues interesting, I've
got a whole talk about the basics of IP which can you [check out the slides for](/talks/ip/)
or come see the talk at [PyGotham](https://2017.pygotham.org/) or [DevOpsDays Hartford](https://www.devopsdays.org/events/2017-hartford/welcome/).

As I said at the start, I am not an attorney so if you have specific questions
about React or IP law in general I'm happy to do my best to help but please also
talk to a lawyer or your company's legal department if you have one.




