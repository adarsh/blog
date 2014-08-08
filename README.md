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


### Deploy to GitHub Pages (source at `adarsh.github.io`)

Run the rake task to deploy the site and purge cache:

    $ middleman deploy
    $ open adarsh.io

Big thanks to [Harlow Ward](https://github.com/harlow) for the Middleman template.
