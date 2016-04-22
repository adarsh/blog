---
title: Testing Active Job Error Handling
description: How to write tests for ActiveJob's error handling behavior

author: Adarsh Pandit
category: programming
date: 2015-05-28
logo: ruby_on_rails_logo.png
published: true
tags: [ruby, rails, ruby on rails, ActiveJob, RSpec, Exceptions, Error Handling, Airbrake]
---

[As I wrote yesterday][1],
I'm a big fan of the new ActiveJob interface
for background jobs in Rails.

[1]: /using-globalid-with-alternative-primary-keys

As a dedicated Test-Driven Developer,
I like to write tests first
when developing features,
including things happening in background jobs.

I have some errors appearing in the background jobs
where I email lots of people
for [AsyncStandup][2]
(a side project using email to keep up to date with your team).

[2]: //asyncstandup.com?utm_source=adarsh.io

But exceptions were not being sent to Airbrake
and debugging was difficult.

So I wrote a test using [RSpec's handy `allow_any_instance_of` stub][3]:

[3]: https://relishapp.com/rspec/rspec-mocks/v/3-2/docs/working-with-legacy-code/any-instance

```ruby
describe DigestEmailJob, 'errors' do
  it 'reports errors' do
    error = StandardError.new('Hey! Something went wrong!')
    allow_any_instance_of(DigestEmailJob).to receive(:perform).
      and_raise(error)
    allow(Airbrake).to receive(:notify)

    DigestEmailJob.perform_now

    expect(Airbrake).to have_received(:notify).with(error)
  end
end
```

I stubbed the `.perform` method on any instance of the job class here,
which is generally inadvisable.
It is too broadly scoped to understand clearly what is stubbed
and can add confusion to the tests.
Also the RSpec maintainers [advise caution][3]:

> This feature is sometimes useful when working with legacy code, though in general we discourage its use for a number of reasons:
>
> * The rspec-mocks API is designed for individual object instances, but this feature operates on entire classes of objects. As a result there are some semantically confusing edge cases. For example, in `expect_any_instance_of(Widget).to receive(:name).twice` it isn't clear whether each specific instance is expected to receive name twice, or if two receives total are expected. (It's the former.)
> * Using this feature is often a design smell. It may be that your test is trying to do too much or that the object under test is too complex.
> * It is the most complicated feature of rspec-mocks, and has historically received the most bug reports. (None of the core team actively use it, which doesn't help.)


However, in this case, there isn't a good alternative
to simulating a raised exception,
so we'll proceed with caution.

To make the test pass,
I added exception handling to ActiveJob
using the `rescue_from` handler:

```ruby
class DigestEmailJob < ActiveJob::Base
  def perform
    ...
  end

  rescue_from(StandardError) do |exception|
    Airbrake.notify(exception)
  end
end
```

Hat tip to [Isaac Seymour][isaac]
for pointing out the `any_instance_of` solution.
See the original discussion [here][github-discussion].
Thanks!

Also check out Isaac's nice [rspec-activejob][rspec-activejob] matchers.

[isaac]: https://github.com/isaacseymour
[github-discussion]: https://github.com/gocardless/rspec-activejob/issues/15#issuecomment-106041065
[rspec-activejob]: https://github.com/gocardless/rspec-activejob
