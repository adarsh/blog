---
title: Episode 4, A New Blog
date: 2013-08-08
description: How to import a WordPress blog into Octopress
author: Adarsh Pandit
tags: [octopress, blog, github pages, themes, zsh]
logo: http://blog.pixelingene.com/images/2011-09-12-switching-to-the-octopress-blogging-engine/octopress_logo.png
---

This is a new  Octopress blog set up here at adarsh.github.io using GitHub
User Pages (different from Group/Repo pages).

How I set it up (cribbed heavily from [this post by Paul Sturgess][1]):

<!-- more -->

Initial setup
=============

Create a new repo named `username.github.io` cloned from the Octopress repo:

```zsh
$ git clone git://github.com/imathis/octopress.git adarsh.github.io
$ cd adarsh.github.io
```


I'm not sure it matters much, but I use ruby 2.0.0-p247 under rbenv:

```zsh
$ echo '2.0.0-p247' > .ruby-version
$ gem install bundler
$ bundle install
```

Skip the installation of the default theme (`$ rake install`) - we'll install
something nicer in a moment.

Setup GitHub User Pages
=======================

Octopress has a nice Rake task for setting up a blog under GitHub Pages:

```zsh
$ rake setup_github_pages
```

This does a bunch of stuff. I'll let [Paul][1] explain more clearly:

> This task does quite a few things. The most important is that it creates a new _deploy directory that is another git repository. This is where Octopress generates the flat website for deployment to the master branch of your repo on Github.
>
> All the Octopress code used to generate the website into the `_deploy` directory now lives in new branch called source. Note in the source branch the `.gitignore` includes `_deploy` so it doesn’t get committed in two places!
>
> This sounds more complicated than it is, Octopress has rake tasks to make this really easy to manage. It’s worth pushing up at this point to check everything works before tinkering:
>
>`$ rake generate deploy`
>
> This copies the generated files into _deploy, adds them to git, commits and pushes them up to the master branch.
>
> Visit http://yourgithubusername.github.io and check it out

Add a Theme
===========

While Octopress is pretty great out of the box, the default theme is a little
stale. I'm using [LeanPress][2]:

```zsh
$ git clone https://github.com/tlvince/leanpress.git .themes/leanpress
$ rake install\['leanpress'\]
$ rake generate
```

There's a gotcha here for zsh users: Under zsh, these rake commands with square
brackets need escaping. I think it's okay to skip this under bash.

Configure `_config.yml`
=======================

There's a ton of stuff in here, but for now, just edit the stuff at the top:

```
# ----------------------- #
#      Main Configs       #
# ----------------------- #

url: http://adarsh.github.io
title: adarsh.github.io
subtitle: a development blog
author: Adarsh Pandit
simple_search: http://google.com/search
description:
```

Add Posts
=========

```zsh
$ rake new_post\['Episode 4: A New Blog'\]
```

This generates a `source/_posts/2013-08-08-a-new-hope.markdown` file. Edit it up
and set up preview:

```zsh
# In another pane/tab
$ rake watch     # will regenerate the html/css after any changes

# In yet another pane/tab
$ rake preview   # preview page at http://localhost:4000
```

Deploy again and commit the source:

```zsh
$ rake generate deploy
$ git commit -am 'First Commit and post!'
$ git push
```

Profit
======

Profit!

[1]: http://paulsturgess.co.uk/blog/2013/04/24/hello-octopress-and-github-pages/
[2]: https://github.com/tlvince/leanpress
