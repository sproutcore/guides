SproutCore Guides
=================

This is the official documentation for the [SproutCore](http://www.sproutcore.com) framework.

Go to the [SproutCore Guides](http://guides.sproutcore.com) homepage and check it out.

Want to make changes to the SproutCore documentation, here's how.

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
        $ bundle install --binstubs

## Make Changes and Additions

Before you make any changes, you'll want to pull in any upstream changes and create a new topic branch in git.

    $ git fetch upstream
    $ git checkout -b <branchname>

You'll do most of your work inside the source/ directory.

## Preview Your Changes

The guides gem comes with a built in webserver so you can see what the guides on your local machine will look like when they're published to guides.sproutcore.com. To get this webserver running, do this from the guides directory:

    $ guides preview

Now you can preview the guides by pointing a web browser to `localhost:9292`. This preview will keep itself updated as you make changes to the guides; all you have to do is refresh your browser window to see your latest changes.

By default, preview will show guides that are still under construction, even though under construction guides are not displayed on guides.sproutcore.com. If you would like to see only guides that **will** be deployed, use the `--production` option like so:

    $ guides preview --production

## Submitting Changes

[pull request](https://help.github.com/articles/using-pull-requests)

## More Information

For more information on SproutCore Guides, including committing your additions and changes, see the [contribute guide](http://guides.sproutcore.com/contribute.html).

If you have any questions, the team can be reached at [@sproutcore](http://twitter.com/#!/sproutcore)
or [#sproutcore](irc://irc.freenode.net/sproutcore)
