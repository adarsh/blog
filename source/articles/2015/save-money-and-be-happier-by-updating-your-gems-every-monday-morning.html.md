---
title: Save Money and Be Happier by Updating Your Gems Every Monday Morning
description: An approach to avoiding the technical debt of gem drift

author: Adarsh Pandit
category: writing
date: 2015-11-16
logo: ruby_on_rails_logo.png
published: true
tags: [ruby on rails, update gems, versions, technical debt, upgrade gems]
---

As a newcomer to Rails,
understanding Gems and the Gemfile
is fairly straightforward:
You include a gem that you need
and you get it included everywhere.

We don't often think about it,
but that last bit is important:
we are literally `include`ing
all of the code from each gem
into our application, all the time.

There are other implications of
this `include` behavior which should be considered,
like speed
but here I'm going to address one:
Gem Drift and the associated cost.

## An Example

Let's say I include an auth gem called `huge_bouncer`
in my app to do authentication and authorization.
(Note: this is not a real gem, but a name I love.
Feel free to use it but please attribute here
so I can feel good about my gem-naming skills.)

Over time, the nice person who wrote `huge_bouncer`
reviews issues and PRs at night and on weekends
and keeps development moving at a good pace.
She is a saint and deserves an award
or at least you should buy her a beer
if you run into her at conference.

Newly released gem versions are, for the most part,
new features and security patches
(particularly in auth libraries).
Not keeping up-to-date with new features
is no big deal in the short term, really.
I mean, yes, they built a nice OAuth DSL
but we don't use that in our app, so who cares.

Not keeping up to date with security patches is a bigger issue.
You know who keeps up with those updates?
[Bad people who want to target your innocent webapp.][1]

You need to keep your app up to date,
so how do you do it?

[1]: http://www.phrack.org/papers/attacking_ruby_on_rails.html

## Enter Robots
Anything you need to do routinely
should be automated, right?
You can use [bundler-audit]
to regularly check for _reported_ security fixes.

[bundler-audit]: https://github.com/rubysec/bundler-audit

It works like this:

Add the gem:

```ruby
# Gemfile
# ...
group :development, :test do
  gem 'bundler-audit', require: false
end
```

Then set it up to check for vulnerabilities
when you run the test suite:

```ruby
# Rakefile
# ...
task default: [:spec]
task default: ['bundler:audit']
```

```ruby
# lib/tasks/bundler_audit.rake
if Rails.env.development? || Rails.env.test?
  require 'bundler/audit/cli'

  namespace :bundler do
    desc 'Updates the ruby-advisory-db and runs audit'
    task :audit do
      %w(update check).each do |command|
        Bundler::Audit::CLI.start [command]
      end
    end
  end
end
```

Be sure to [add it to your CI as well][2].

[2]: /automatically-check-gem-vulnerabilities-in-circle-ci

Note there are [all sorts] of nice
[paid services] which also do
this kind of thing.

[all sorts]: https://appcanary.com/
[paid services]: https://www.datadoghq.com/lpg/

Great! We're covered, right?

Sorta. This will check the database
of _reported_ security issues
which is some subset of released security patches.
I don't blame gem maintainers for this:
again, they're working in their spare time
for the greater good.
Expecting them to keep up to date
with more admin activities
isn't really fair.

So what can we do?

## A Path Forward

I started doing something on projects recently
which colleagues either don't care about
or appreciate me doing:

Monday morning,
I take 15 minutes
and run `bundle update`.

Then I open a PR with the changes,
and hopefully deploy within the hour
once I get code review.

That's it.

The changes are very often quite minor
and when they're not,
I look at the gem's release notes
and figure out what the changes are.
If it's a big change,
say new deprecations or
breaking changes,
I fix them in about 30 minutes.
People are pretty good about [SemVer].

Remember software is best changed
in small iterations,
and updating gems
is still shipping software changes.

[SemVer]: http://semver.org/

> "HAHA, oh great plan but we are _way_ out of date already and can't just jump right up to current."

Of course. So here's what you do:
Go into the lockfile (`Gemfile.lock`)
and figure out what the specific versions
are of things which are really far out of date.
For example, let's say `huge_bouncer`
is now at version 2.0.7,
but we don't know what we are locked at:

```ruby
# Gemfile.lock
# ...
  huge_bouncer (1.2.4)
    bcrypt
    email_validator (~> 1.4)
    rails (>= 3.1)
```

We can use the [twiddle-waka] operator to say
"when updating this gem,
only do so to the next major version,"
like so:

[twiddle-waka]: https://robots.thoughtbot.com/rubys-pessimistic-operator

```ruby
# Gemfile
gem 'huge_bouncer', '~> 1.2.4'
```

Okay so now we are not moving that much,
and can do a safe `bundle_update`
without moving the versions too much.
In this case, let's say we get up to 1.2.8.
This is an improvement!

Then, when we next have time,
we can loosen the restrictions a bit,
`bundle update` again,
and see if all is okay.

Remember, we want to make and deploy
small changes, so don't get all crazy.

## Wait, What About Robots Again?

Shouldn't you build or pay for some service
which does this for you?

*NO*.

You are including a heck-ton of other code
and you should be aware of
how it is changing.
Maybe not in minute detail,
but it's a lot of code
which you are shipping,
so you should read the label.

## The Money Saved

No one will care if you update gems
every Monday morning
but you are saving your company
lots of money.

I asked some friends
to estimate the cost of
getting totally current with their gems
at their company or clients
and here's what they said:

* Upgrading Rails 2 to 3 is about 16+
developer-weeks, so about a $100-200k problem
* Upgrading Rails 3 to 4 is about half of that.

Assume the bigger the codebase,
or the older it is,
the higher the cost.

So no, it's not glamorous work
but someone should thank you for doing it.

Also, if you are up to date,
others will pick up the slack for you
_because you've made it so easy_.
Good job! You are a minor hero!

## Acknowledgements

Big thanks to [Jason Draper]
for helpful edits
and promising to argue with me about this
in public.

Also, thanks to the people who
shared estimates or anecdotes
of what it costs to upgrade
Gem suites.

[Jason Draper]: https://twitter.com/drapergeek
