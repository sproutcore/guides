SproutCore Guides
=================

This is the official documentation for the [SproutCore](http://www.sproutcore.com) framework. You can see it live at the [SproutCore Guides](http://guides.sproutcore.com) homepage.

Want to make changes to the SproutCore documentation? This document contains a brief explanation of how to do so. For a more thorough explanation, see the [Contributing Guide](http://guides.sproutcore.com/contribute.html).

## Get the Source

1. [Fork](https://help.github.com/articles/fork-a-repo) the [SproutCore Guides repository](https://github.com/sproutcore/guides) on [GitHub](http://github.com).

2. Clone the fork on to your local machine.

        $ git clone git://github.com/<yourname>/guides.git

3. Add the main SproutCore Guides repository as a remote so you can fetch updates.

        $ cd guides
        $ git remote add upstream git://github.com/sproutcore/guides.git

## Install the Guides Ruby gem

- Normal gem install

        $ gem install guides

- Install with Bundler

    Alternatively you can use Bundler to install the guides gem. This has the benefit of ensuring that you are using the correct version of the guides gem.

        $ gem install bundler
        $ cd guides
        $ bundle install

## Before Making Changes

Before you make any changes, you'll want to pull in any upstream changes and create a new topic branch for your changes.

    $ git pull upstream/master
    $ git checkout -b <branchname>

## Making Changes

Guides are written in a modified version of the [Textile](http://en.wikipedia.org/wiki/Textile_(markup_language)) markup language.

The best way to familiarize yourself with how to use Textile is to check out the other guides, which are located in the `source` directory (where you'll be doing most of your work).

## Preview Your Changes

The guides gem comes with a built in webserver so you can see what the guides on your local machine will look like when they're published to [guides.sproutcore.com](http://guides.sproutcore.com). To get this webserver running, do this from the `guides` directory:

    $ guides preview

Now you can preview the guides by pointing a web browser to `localhost:9292`. This preview will keep itself updated as you make changes to the guides; all you have to do is refresh your browser window to see your latest changes.

## Submitting Changes

You can get your changes and additions included by creating a [pull request](https://help.github.com/articles/using-pull-requests) on GitHub.

## More Information

For more information on SproutCore Guides, including a more in depth look at committing your additions and changes, see the [contributing guide](http://guides.sproutcore.com/contribute.html).

If you have any questions, the team can be reached at [@sproutcore](http://twitter.com/#!/sproutcore) on Twitter, in the [#sproutcore-dev](irc://irc.freenode.net/sproutcore-dev) IRC channel on [Freenode](http://freenode.net/), or at the [SproutCore Google Group](http://groups.google.com/group/sproutcore-dev).
