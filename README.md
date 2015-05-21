## Adarsh Pandit Personal Blog

This repo contains the HTML, CSS, JavaScript, and images for the adarsh.io
blog as well as its blog posts in Markdown.


### Installation

Clone the repository and bundle.

    $ git clone git@github.com:adarsh/blog.git
    $ cd blog
    $ bundle

Boot the middleman server.

    $ middleman

[Bam!](http://0.0.0.0:4567)


### Writing

Create a new post:

    $ middleman article "TITLE_OF_ARTICLE"

If you'd like to change the default template,
edit `source/new_article_template.html.erb`


### Deploy to GitHub Pages (source at `adarsh.github.io`)

Run the rake task to generate the markup and deploy the site:

    $ middleman deploy
    $ open http://adarsh.io

Big thanks to [Harlow Ward](https://github.com/harlow) for the Middleman template.
