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
That means we can access it from other instance methods.
Not a huge deal, but it's intended for internal use when memoizing.

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

## Instance Variables in Controllers

Also, as my friend [Gabe][9] [pointed out to me][10],
it's even more important to use an underscore
when memoizing in Rails controllers:

> "Since all controller ivars are available in the view,
> it's often helpful to mark ivars that should only be used
> in the controller with a leading underscore.
> That also allows things like this,
> where `@users` is exposed to the view and `@_users` is just used for
> memoization:"
>
> ```ruby
> def index
>   @posts = posts.where(user: users.where(has_post: true))
>   @users = users.where(confirmed: true)
> end
>
> private
>
> def users
>   @_users = User.all
> end
> ```

It's good to have smart friends.

[4]: https://github.com/bbatsov/ruby-style-guide/#syntax
[5]: https://stackoverflow.com/questions/5893163/what-is-the-purpose-of-the-single-underscore-variable-in-python
[6]: https://prime.haskell.org/wiki/Underscore
[7]: http://lua-users.org/wiki/LuaStyleGuide
[8]: http://i.giphy.com/F3G8ymQkOkbII.gif
[9]: https://twitter.com/gabebw
[10]: https://github.com/adarsh/blog/pull/61#issuecomment-253646457



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
