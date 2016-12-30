---
title: Smack Wack Traffic with this Rack Attack Hack
description: 

author: Adarsh Pandit
category: writing
date: 2016-12-30
logo: terminal_icon.png

published: false
no_index: true
tags: []
---

Recently,
I came across a lot of suspicious traffic
on a client project
when I turned on exception tracking.

It looked like this:

```
ActionController::RoutingError: No route matches [GET] "/wp-login.php"
```

Hey! Knock it off, you ruffians!
This isn't a WordPress site (not that there's anything wrong with that)!

## What is This?

This is called "penetration testing".
It's where not-nice people send lots of requests
at your site, trying to learn things about it,
presumably to do hack your site and do not-nice things.

In this case,
someone wants to know if we are running a WordPress site
(we are not, it's Rails).

Normally, we wouldn't care much.
Some call this "The background noise of the internet".

But after we installed exception tracking,
each of these attempts eats away at our plan's monthly exception limits.

No!

Let's block them.


## The Simplest Security System


Add it to your `Gemfile`:

```ruby
# ...
group :staging, :production do
  gem 'rack-attack'
end
```

```ruby
# config/initializers/rack-attack.rb
class Rack::Attack
  Rack::Attack.blocklist('Block penetration testers') do |request|
    ENV.fetch('BLOCKED_REQUEST_PATHS', '').split(' ').include?(request.path)
  end
end
```

```ruby
# config/initializers/rack-attack.rb
class Rack::Attack
  Rack::Attack.blocklist('Block penetration testers') do |request|
    blocked_patterns = ENV.fetch('BLOCKED_REQUEST_PATTERNS', '').split(' ')

    Regexp.union(blocked_patterns) === request.path
  end
end
```
