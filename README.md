SproutCore Guides
=================

These are the official guides for the [SproutCore](http://www.sproutcore.com) framework. You can see them live at the [SproutCore Guides
homepage](http://guides.sproutcore.com).

This document contains a brief overview of how to contribute changes and additioins to the SproutCore Guides. For an in-depth explanation, see the
[Contributing Guide](http://guides.sproutcore.com/contribute.html).

## Getting the Source Code

1. [Fork](https://help.github.com/articles/fork-a-repo) the [SproutCore Guides repository](https://github.com/sproutcore/guides) on [GitHub](http://github.com).

2. Clone the fork on to your local machine.
    ```bash
    $ git clone git://github.com/<yourname>/guides.git
    ```

3. Add the main SproutCore Guides repository as a remote so you can fetch updates.
    ```bash
    $ cd guides
    $ git remote add upstream git://github.com/sproutcore/guides.git
    ```

## Installing Prerequisites

The SproutCore guides use the [Node](http://nodejs.org/)-powered [DocPad](http://docpad.org/) framework. In order to contribute to the guides,
you will first need to install Node from [http://nodejs.org/](http://nodejs.org/).

Next, install the docpad framework (note: you may need to use `sudo` for this):

```bash
$ npm install -g docpad
```

Finally, change into the guides directory, checkout the docpad-guides branch, and install the necessary development dependencies:

```bash
$ cd ~/my/dev/directory/sproutcore/guides
$ git checkout docpad-guides
$ npm install
```

You should see a plethora of output similar to the following:

    ...
    npm http 304 https://registry.npmjs.org/keypress
    npm http 304 https://registry.npmjs.org/readable-stream
    npm http 304 https://registry.npmjs.org/underscore
    npm http 304 https://registry.npmjs.org/qs/0.6.5
    npm http 304 https://registry.npmjs.org/commander/0.6.1
    npm http 304 https://registry.npmjs.org/bal-util
    npm http 304 https://registry.npmjs.org/range-parser/0.0.4
    ...

## Before Making Changes

Before you make any changes, you'll want to pull in any upstream changes and create a new topic branch for your changes.

```bash
$ git pull upstream/master
$ git checkout -b <branchname>
```

## Creating or Modifying a Guide

Guides reside in the `src` directory and are written in a modified version of the [Markdown](http://daringfireball.net/projects/markdown/) markup
language. The best way to familiarize yourself with how to use Markdown is to check out the other guides.

Docpad makes it easy to see what the guides on your local machine will look like when they're published to
[guides.sproutcore.com](http://guides.sproutcore.com). To preview your changes, run the following command from the `guides` directory:

```bash
$ docpad run
```

Now point a web browser to [localhost:9778](http://localhost:9778). This preview will keep itself updated as you make changes to the guides; all you have to do is refresh
your browser window to see your latest changes.

## Submitting Your Changes

You can get your changes and additions included by creating a [pull request](https://help.github.com/articles/using-pull-requests) on GitHub using the
topic branch you created above.

## More Information

For more information on the SproutCore Guides, including a more in depth look at committing your additions and changes, see the [contributing
guide](http://guides.sproutcore.com/contribute.html).

If you have any questions, the team can be reached at [@sproutcore](http://twitter.com/#!/sproutcore) on Twitter, in the
[#sproutcore](irc://irc.freenode.net/sproutcore) IRC channel on [Freenode](http://freenode.net/), or at the [SproutCore Google
Group](http://groups.google.com/group/sproutcore).
