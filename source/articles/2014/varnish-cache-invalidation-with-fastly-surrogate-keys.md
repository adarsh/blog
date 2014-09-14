---
title: Varnish Cache Invalidation with Fastly Surrogate Keys
date: 2013-12-12
author: Harlow Ward
description: I've been seeing seriously fast results using Fastly's hosted Varnish service. This post covers purging the Varnish Page cache with Surrogate Keys.
category: rails
published: false
---

We've been using [Fastly](http://www.fastly.com/) on a few projects at
[HotelTonight](http://www.hoteltonight.com) and I recently moved this blog onto their service too. I've seen some [tremendous performance gains](http://www.hward.com/scale-rails-with-varnish-http-caching-layer) and have been clocking some [excellent pagespeed scores](https://twitter.com/futuresanta/status/410327558618492928/photo/1).

However, in the beginning I did feel some pain...

> There are only two hard things in Computer Science: cache invalidation and naming things.
> -- Phil Karlton

Out of the box Varnish supports [flushing of URLs](https://www.varnish-cache.org/docs/3.0/tutorial/purging.html) via the HTTP PURGE method. This works pretty well for simple one-to-one mappings of resources to URLs. However, complexity can arise when a URL depends on multiple resources within an application.

Luckily Fastly has done most of the heavy lifting for us and added [Surrogate Keys](http://www.fastly.com/blog/surrogate-keys-part-1) to their service offering.

TL;DR we can return an HTTP header `Surrogate-Keys` that will allow us to build a many-to-many relationship between keys-and-pages within our site. When we purge a key; any page associated with that key will also be purged.

## Creating Surrogate Keys

Using the codebase from this blog site as an example we'll walk through the steps to set up `Surrogate-Keys` in a Ruby on Rails application.

Lets first add two convenience methods to our `Article` class so instances of it can generate their own keys.

```ruby
# app/models/article.rb
class Article < ActiveRecord::Base
  # ...

  def resource_key
    "#{collection_key}/#{id}"
  end

  def collection_key
    self.class.table_name
  end
end
```

Then we can use the `collection_key` and `resource_key` methods in the `ArticlesController` to generate the appropriate keys.

```ruby
class ArticlesController < ApplicationController
  before_filter :set_cache_control_headers

  def index
    @articles = Article.published
    set_surrogate_header 'articles', @articles.map(&:resource_key)
  end

  def show
    @article = Article.find(params[:id])
    set_surrogate_header @article.resource_key
  end

  private

   def set_surrogate_header(*keys)
     response.headers['Surrogate-Key'] = keys.join(' ')
   end
end
```

The `set_surrogate_header` method adds a new header to the Rails response and sets the value to the keys passed in (if we pass in multiple keys it will join them together into one space delimited string).

Lets verify we're getting the expected response:

```
curl -X HEAD http://localhost:5000 -I
> HTTP/1.1 200 OK
> Surrogate-Key: articles articles/1 articles/2 articles/3

curl -X HEAD http://localhost:5000/articles/2 -I
> HTTP/1.1 200 OK
> Surrogate-Key: articles/2
```

## Purging Surrogate Keys

When we modify an Article through the CMS we'll want to purge the article "index page" and the "article detail" (as well as any other pages that might include the Article in question).

To [DRY](http://en.wikipedia.org/wiki/Don't_repeat_yourself) things up we'll use a [model concern](http://37signals.com/svn/posts/3372-put-chubby-models-on-a-diet-with-concerns) and extract the convenience methods used for building Surrogate Keys. We'll also add two new methods `purge_resource_key` and `purge_collection_key` which give models the ability to purge their prospective keys.

```ruby
# app/models/concerns/edge_cachable.rb
module EdgeCachable do
  extend ActiveSupport::Concern

  def purge_resource_key
    Fastly.purge_key(resource_key)
  end

  def purge_collection_key
    Fastly.purge_key(collection_key)
  end

  def resource_key
    "#{collection_key}/#{id}"
  end

  def collection_key
    self.class.table_name
  end
end
```

Include the module from the `Article` mode.

```ruby
# app/models/article.rb
class Article < ActiveRecord::Base
  include EdgeCacheable

  # ...
end
```

Finally, let's call the purge methods when an `Article` is created or updated.

```ruby
# app/controllers/articles_controller.rb
class ArticlesController < ApplicationController
  # ...

  def create
    @article = Article.new(article_params)

    if @article.save
      @article.purge_collection_key
      redirect_to @article
    else
       render 'new'
    end
  end

  def update
    @article = Article.find(params[:id])

    if @article.update_attributes(article_params)
      @article.purge_resource_key
      redirect_to @article
    else
      render 'edit'
    end
  end

  private

  def article_params
    # ...
  end
end
```

Whenever a new Article is created the `articles` key will be purged (which will bust the cache for index page). Similarly, when an article is updated it will purge `articles/:id` which will bust the cache for the article page, and  the index page.

If we were to add new pages to the site such as "Tags" or "Popular" we can use the same Surrogate Keys from Articles to programmatically purge the cache for those new pages too.
