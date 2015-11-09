---
title: Bundler Failing on El Capitan
description: How to fix OpenSSL header issues after upgrading to OS X El Capitan

author: Adarsh Pandit
category: rails
date: 2015-11-09
logo: terminal_icon.png
published: true
tags: [bundler, ruby on rails, el capitan, openssl, os x, openssl]
---

After updating to El Capitan,
installing new gems
started to fail.
It looked something like this:

```
Building native extensions.  This could take a while...
ERROR:  Error installing awesome_gem_name:
    ERROR: Failed to build gem native extension.

checking for rb_trap_immediate in ruby.h,rubysig.h... no
checking for rb_thread_blocking_region()... no
...
CFLAGS=-O3 -I/Users/haven/.sm/pkg/active/include -fPIC -mmacosx-version-min=10.7 -pipe  -Wall -Wextra -Wno-deprecated-declarations -Wno-ignored-qualifiers -Wno-unused-result
CPPFLAGS=-D_XOPEN_SOURCE -D_DARWIN_C_SOURCE -D_DARWIN_UNLIMITED_SELECT -D_REENTRANT $(DEFS) $(cppflags) -Wall -Wextra -Wno-deprecated-declarations -Wno-ignored-qualifiers -Wno-unused-result
checking for clock_gettime()... no
checking for gethrtime()... no
creating Makefile

make "DESTDIR=" clean

make "DESTDIR="
compiling binder.cpp
```

But here's the important part:

```
In file included from binder.cpp:20:
./project.h:116:10: fatal error: 'openssl/ssl.h' file not found
```

## [Wha happened?](https://www.youtube.com/watch?v=k5Cfhooa1bI)

As of OS X El Capitan,
Apple no longer provides OpenSSL headers.

"But wait, I have OpenSSL!," you cry.

```
$ which openssl
/usr/bin/openssl
```

Yes you do, but you lack the [C _headers_]
which some gems use to build
native extensions.

Think of the headers as the source code
and `/usr/bin/openssl` as the compiled binary.

Apple no longer ships the headers
on which many gems with native C extensions depend.
For more on why, [read this post]

[read this post]: https://lists.apple.com/archives/macnetworkprog/2015/Jun/msg00025.html
[C _headers_]: http://www.tutorialspoint.com/cprogramming/c_header_files.htm

```bash
# On earlier OS X:
$ ls /usr/include/openssl/ssl.h
/usr/include/openssl/ssl.h

# On El Capitan:
$ ls /usr/include/openssl/ssl.h
ls: /usr/include/ssl.h: No such file or directory
```


## [Fix It!](https://www.youtube.com/watch?v=yo3uxqwTxk0)

You can install your own OpenSSL headers
using either Homebrew or MacPorts.
I'm a Homebrew guy so let's go that route.

First let's uninstall whatever you have,
if anything:

```
$ brew uninstall openssl --force
```

The `--force` bit will "remove out-of-date keg-only brews as well"
(see the `man brew` page).

I couldn't get this to work
unless I updated my
XCode Command Line tools
after upgrading to El Capitan.

So let's do that:

```
$ xcode-select --install
```

Be sure to agree to everything,
not just in the dialogue boxes OS X presents,
but in life - just try to say yes more.
(NOTE: Any philosophical disagreements
are beyond the scope of this blog post
and left as an exercise for the reader.)

When that is finished,
then install OpenSSL
and force symlinking
into the appropriate places:

```
$ brew update
$ brew install openssl
$ brew link --force openssl
```

Now your `bundle install` should work no problem!

### Acknowledgements

Thanks to Gabe Berke-Williams for helpful edits.
Read [his amazing blog]
or follow [his pun-filled Twitter feed]
or investigate [his myriad of interesting GitHub projects.]

[his amazing blog]: http://gabebw.com/
[his pun-filled Twitter feed]: https://twitter.com/gabebw
[his myriad of interesting GitHub projects.]: https://github.com/gabebw
