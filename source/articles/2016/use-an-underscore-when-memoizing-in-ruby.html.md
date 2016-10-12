---
title: Use an Underscore When Memoizing in Ruby
description: Let other developers know you don't want them to use your internals

author: Adarsh Pandit
category: writing
date: 2016-10-12
logo: ruby_on_rails_logo.png

published: true
tags: [ruby, rails, style, memoization, underscore, instance variable]
---


## TLDR;

Do this:

```ruby
def expensive_method
  @_expensive_method ||= #something
end
```

Not this:

```ruby
def expensive_method
  @expensive_method ||= #something
end
```

![memoization](memo_pad.png)

## Memoization Basics

The act of "memoizing" a method means to
locally cache the result of an expensive operation
on the first method invocation
and reusing it thereafter.

It is functionally equivalent to:

```ruby
def expensive_method
  @expensive_method = @expensive_method || this_expensive_operation
end
```

## Naming

By convention,
you typically see developers name the instance variable after the method.
Likely, this is because manual instance variable accessors
used to look like this:

```ruby
def expensive_method
  @expensive_method
end
```

Nowadays, we usually write `attr_reader :expensive_method`.

## Unused Variables

Keen readers will note
we are actually instantiating an instance variable here.
That means we can access it from outside the class
(assuming it's public):

```ruby
irb(main):001:0> def method_name; @ivar ||= 207; end
:method_name
irb(main):002:0> @ivar
nil
irb(main):003:0> method_name
207
irb(main):003:0> @ivar
207
```

This is inadvertently adding to the class's public API.
We should avoid this because we want to keep the
API surface area minimal, to the extent possible.

Enter the underscore.

It is convention [in][7] [many][5] [languages][6] [including Ruby][4]
to prepend an unused variable name
with an underscore.

The underscore serves as a signal to other developers
saying "Hey! Don't use this!".

We should do the same when memoizing:

```ruby
def expensive_method
  @_expensive_method ||= #something
end
```
This is, of course, a style preference with no functional impact.
It's also [just my opinion, man][8].


[4]: https://github.com/bbatsov/ruby-style-guide/#syntax
[5]: https://stackoverflow.com/questions/5893163/what-is-the-purpose-of-the-single-underscore-variable-in-python
[6]: https://prime.haskell.org/wiki/Underscore
[7]: http://lua-users.org/wiki/LuaStyleGuide
[8]: http://i.giphy.com/F3G8ymQkOkbII.gif


## Further Reading

* Justin Weiss has [a nice article on Memoization][1]
  including links to the history in Rails, handling nil results, and more.
* Vaidehi Joshi [has a nice bit on the history of memoization itself][3].
  She writes about how it dates back to 1968. (!)
* Gavin Miller wrote [a great article][2] covering when to memoize and when not
  to.
* Some gems which make this easier: [memoist], [memist]

[1]: http://www.justinweiss.com/articles/4-simple-memoization-patterns-in-ruby-and-one-gem?utm_source=adarsh.io&utm_medium=blog
[2]: http://gavinmiller.io/2013/basics-of-ruby-memoization?utm_source=adarsh.io&utm_medium=blog
[3]: https://vaidehijoshi.github.io/blog/2015/11/10/methods-to-remember-things-by-ruby-memoization?utm_source=adarsh.io&utm_medium=blog
[memist]: https://github.com/adamcooke/memist
[memoist]: https://github.com/matthewrudy/memoist
