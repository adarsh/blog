---
title: Using GlobalID with Alternative Primary Keys
description: Monkeypatching `.find` in ActiveRecord models can lead to confusion

author: Adarsh Pandit
category: programming
date: 2015-05-27
logo: ruby_on_rails_logo.png
published: true
tags: [ruby, rails, ruby on rails, GlobalID]
---

I like the new universal job interface for Rails, [ActiveJob][1].
I've done this kind of job class creation before, usually with [DelayedJob][2].
It makes job behavior much easier to test inside an object
(or "PORO" as the kids say)
and encapsulates the logic nicely.

[1]: https://github.com/rails/rails/tree/master/activejob
[2]: https://github.com/collectiveidea/delayed_job

However note the following important attributes of background jobs in Rails:

* ActiveRecord models are dynamic and change frequently.
* Background jobs can have a variable amount of time
between when they are created and when they run.

Together, these two facts mean we can't directly pass in AR objects
when creating a job
because the model attributes may change
 between when we create the job and when it runs.
That could be bad.

To avoid these errors, you can pass in
an ActiveRecord object's ID as a parameter
when you enqueue a job.
Then when the job is ready to run,
you can look up the model
and have the current state:

```ruby
# app/jobs/email_user_job.rb
class EmailUserJob
  def initialize(user_id)
    @user_id = user_id
  end

  def perform
    UserMailer.send(user).deliver
  end

  private

  attr_reader :user_id

  def user
    User.find(user_id)
  end
end


# Somewhere
job = EmailUserJob.new(user.id)
Delayed::Job.enqueue(job)
```

I love the implementation of [GlobalID][3] with ActiveJob
because it eliminates this dehydrate-rehydrate cycle.

[3]: https://github.com/rails/globalid

With GlobalID/ActiveJob, now we can just pass in the AR object directly:

```ruby
# app/jobs/email_user_job.rb
class EmailUserJob < ActiveJob::Base
  def initialize(user)
    @user = user
  end

  def perform(user)
    UserMailer.send(user).deliver
  end
end

# somewhere
EmailUserJob.perform_later(user)
```

Nice! How does it work?

GlobalID creates a URI with the app name, model name, and primary key:

```ruby
user_guid = User.find(1).to_global_id
# => #<GlobalID:0x007f87cc9f96c8 @uri=#<URI::GID gid://app-name/User/1>>
user_guid.to_s
#=> "gid://app-name/User/1"
```

Super intuitive, right?
You can also see how this would be useful across apps
in a service-oriented architecture.

This is all great except I ran into this problem recently while using GlobalID:

```ruby
irb(main):007:0> team = Team.find(1)
=> #<Team id: 1, created_at: "2015-05-07 17:08:14", updated_at: "2015-05-07 17:08:14", token: "bdfab17ca84712d2" 10>

irb(main):008:0> gid = team.to_global_id
=> #<GlobalID:0x007f79dc7b1d00 @uri=#<URI::GID gid://app-name/Team/4>>

irb(main):009:0> GlobalID::Locator.locate(gid)
  Team Load (1.6ms)  SELECT  "teams".* FROM "teams" WHERE "teams"."token" = $1 LIMIT 1  [["token", "4"]]
  Team Load (1.6ms)  SELECT  "teams".* FROM "teams" WHERE "teams"."token" = $1 LIMIT 1  [["token", "4"]]
ActiveRecord::RecordNotFound: Couldn't find Team
        from /app/vendor/bundle/ruby/2.2.0/gems/activerecord-4.2.1/lib/active_record/core.rb:196:in `find_by!'
        from /app/vendor/bundle/ruby/2.2.0/gems/activerecord-4.2.1/lib/active_record/dynamic_matchers.rb:70:in `find_by_token!'
        from /app/app/models/team.rb:7:in `find'
        from /app/vendor/bundle/ruby/2.2.0/gems/globalid-0.3.5/lib/global_id/locator.rb:140:in `locate'
        from /app/vendor/bundle/ruby/2.2.0/gems/globalid-0.3.5/lib/global_id/locator.rb:17:in `locate'
# ...
```

Huh?

Then I realized `Team.find` had been monkeypatched
to use a different primary key:

```ruby
class Team < ActiveRecord::Base
  def self.find(token)
    find_by_token!(token)
  end

  def to_param
    token
  end

  private

  def generate_token
    unless self.token
      self.token = SecureRandom.hex(8)
    end
  end
```

So this is clearly unexpected behavior on the part of GlobalID,
but it makes sense.
I've changed it's URI construction parameters and it doesn't like that.
Until we add a warning of some kind,
the best course of action is to remove the monkeypatch
and do a lookup on the token like:

```ruby
Team.find_by(token: "abc123")
```

I'm really glad to see these libraries in Rails now.
Try them out!
