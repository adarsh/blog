---
title: Automate Gem Vulnerability Checks
description: Add bundle-audit to CircleCI to automate gem security checking

author: Adarsh Pandit
category: programming
date: 2015-06-15
logo: ruby_on_rails_logo.png
published: true
tags: [ruby on rails, gems, bundler, bundle-audit, circleci]
---

Gem authors regularly report security issues
as responsible maintainers
of open-source software.
Unfortunately, unless you follow
every Github repository for every gem
that you use, it's hard to keep up
with news on the dozens of gems you use.

Luckily, we're programmers
who like to write tools for programmers.

Enter [bundle-audit][1],
a handy gem to check
your `Gemfile.lock` for reported vulnerabilities.

[1]: https://github.com/rubysec/bundler-audit

It's easy enough to update the latest vulnerabilities
and scan your lockfile:

```shell
$ gem install bundler-audit
$ bundle-audit update
$ bundle-audit check
```

but who can be bothered to remember to run this frequently?
As developers,
we should rely on computers
to do routine tasks, right?

Let's add an automated check
to our Continuous Integration service.
In this case, we're using [CircleCI][2].

_Note: If you're using [Travis][3],
[see Adam Prescott's nice writeup][4]
for how to do the same there._

[2]: https://circleci.com
[3]: https://travis-ci.org/
[4]: https://aprescott.com/posts/bundler-audit

First, let's add the gem to our development and test environments:

```ruby
# Gemfile
group :development, :test do
  gem 'bundler-audit', require: false
  # ...
```

Now let's add the appropriate command
to our CircleCI build cascade:

```yaml
dependencies:
  pre:
    - gem install bundler rake
  post:
    - bundle exec bundle-audit update && bundle exec bundle-audit check
```

I added this to the "dependencies" group
since it's related to gems,
and ran it after everything else using `post`
to ensure I could run the gem executable.

That's it! Now the build will break
if one of our gems is insecure.
