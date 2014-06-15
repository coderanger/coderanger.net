---
layout: post
title: "Writing DSLs in Javascript"
---

Beginnings
----------

Recently at work I have been building a testing console for our web APIs. It
began very simply, largely influenced by the excellent [Twitter API console](
http://dev.twitter.com/console). This design rapidly descended into a sea of
hacks. The [Hurl](http://hurl.it/) style works well for RESTful, or nearly
RESTful as in Twitter's case, APIs however it was not as effective for our
primarily JSON-RPC based system. My next approach was to make something more
terminal-like, based on the [WTerm](http://plugins.jquery.com/project/wterm)
jQuery plugin. This mapped better to a procedural API, but it still felt very
limited. Specifically it needed variables.

eval()^^w
---------

Given that this was a web site I already had the not insubstantial power of
Javascript at my disposal. My first thought was that I could dynamically
generate functions to map to our API, and then simply use eval() to process
input. This had two major problems; one, I couldn't isolate the namespace of
the terminal from the rest of the page and two, I had no way to deal with the
asynchronous nature of the AJAX calls. To fix the first problem I tried
several variations of restricting the execution environment of eval(), but
I was unable to find an acceptable, cross-browser solution. To deal with the
second I tried various attempts at code generation from the input strings, but
again I left empty handed. All in all, while Javascript is a very powerful
language for scripting pages, it isn't the right tool for embedded DSLs.

Parser 1.0
----------

Once I had decided down the path of writing a custom DSL, my first thought
turned to parsers. WTerm is already a DSL of sorts, but its parser can be
summed up as ``s.split()``. This was enough for their examples, but at the
very least I need quoted strings. Given my massive programmer brain, I
immediately set forth to write such a beast. Below is the final version of it,
with luck it can serve as a warning to others:

{% highlight javascript %}
// Parse arguments
var raw_buffer = value.substring(value.indexOf(command_name)+command_name.length+1).split('');
var args = [];
var buffer = '';
while(raw_buffer.length > 0) {
    // Advance until non-whitespace
    while(raw_buffer.length && raw_buffer[0] == ' ') raw_buffer.shift();
    if(!raw_buffer.length) break;
    // Is this a quoted string?
    if(raw_buffer[0] == '"' || raw_buffer[0] == "'") {
        var quote = raw_buffer.shift(); // Grab the quote
        while(raw_buffer.length && raw_buffer[0] != quote) buffer += raw_buffer.shift();
        if(raw_buffer.length) raw_buffer.shift(); // Discard closing quote
        args.push(buffer);
        buffer = '';
    } else {
        // Number or unquoted text
        while(raw_buffer.length && raw_buffer[0] != ' ' && raw_buffer[0] != '"' && raw_buffer[0] != "'") buffer += raw_buffer.shift();
        // Try it as a number
        var arg = parseFloat(buffer, 10);
        if(!isNaN(arg)) args.push(arg);
        // fallback to a string
        else args.push(buffer);
        buffer = '';
    }
}
{% endhighlight %}

Parser 2.0
----------

Some further Google-fu turned up a very detailed article by Douglas Crockford
on [Top Down Operator Precedence](http://javascript.crockford.com/tdop/tdop.html)
parsers. The example code is conveniently in Javascript, so I set out to adapt
it into a working language. The provided parser is pretty much a working
implementation of the bits of Javascript that I needed out of the box, so only
a few modifications were needed. For starters I changed how name tokens are
handled in ``advance()``:

{% highlight javascript %}
o = scope.find(v);
if(!o) {
    o = scope.define(t);
}
{% endhighlight %}

This means that any name token will be created in the scope it appears in. I
also didn't want things like flow control or functions so I altered the
returned parser to use:

{% highlight javascript %}
var s = expression(0);
{% endhighlight %}

This provided a solid base to build the DSL on, with Javascript literals (
numbers, strings, objects, and arrays), basic math operators, attribute access,
and simple variables.

Interpreter
-----------

Crockford's code only provides a parser, the other half is to have something
to execute that parse tree. Below is a snippet of my callback-based function:

{% highlight javascript %}
switch(node.arity) {
case "literal": cont(node.value); return;
case "name":
    if(!(node.value in variables)) {
        err("Variable \""+node.value+"\" not defined");
        return;
    }
    cont(variables[node.value]);
    return;
case "binary":
    switch(node.value) {
    case "=":
        interpret(node.second, function(value) {
            variables[node.first.value] = value;
            cont(value);
        }, err);
        return;
    case "+":
        interpret(node.first, function(value1) {
            interpret(node.second, function(value2) {
               cont(value1 + value2); 
            }, err);
        }, err);
        return;
    }
}
{% endhighlight %}

It isn't the fastest thing on the block, but it is perfectly adequate for
interactive usage.

Putting it all together
-----------------------

There are still some bits of complexity to hook up the RPC calls to the
interpreter, and in my case setting up OAuth from the browser as well, but
once you are this far down the rabbit hole they will be a walk in the park.
If you are thinking about building a DSL into a web page, I hope this has
pointed you in the right direction, or at least a slightly less wrong one.
