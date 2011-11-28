## Committing Code

So, you're ready to push some code into the public repo?  Here's a list of things you can do to make sure your code gets past the review process.

endprologue.

### Conform to SC Style Guides

Yeah, this is pretty obvious. If you haven't already go [read them](style_guide.html).

### Must Pass JS lint

Javascript can be beautiful and annoying all at the same time.  [Crockford's JSLint](http://www.jslint.com) is a god send and helps check for common mistakes like:

 * Undefined global vars
 * use of `==` and `!=` instead of `===` and `!==`
 * Extra or missing commas

The following JS lint config can be used in combination with the [SproutCore Textmate bundle](https://github.com/sproutit/sproutcore-tmbundle).

Install it at `<path to your Textmate bundles>/SproutCore.tmbundle/Support/bin/prefs.js`
<javascript>
var JSLINT_PREFS = {
    adsafe     : false, // if ADsafe should be enforced
    bitwise    : false, // if bitwise operators should not be allowed
    browser    : true,  // if the standard browser globals should be predefined
    cap        : false, // if upper case HTML should be allowed
    debug      : true,  // if debugger statements should be allowed
    eqeqeq     : true, // if === should be required
    evil       : false, // if eval should be allowed
    forin      : true,  // if for in statements must filter
    fragment   : false, // if HTML fragments should be allowed
    laxbreak   : true,  // if line breaks should not be checked
    nomen      : false, // if names should be checked
    on         : false, // if HTML event handlers should be allowed
    passfail   : false, // if the scan should stop on first error
    plusplus   : false, // if increment/decrement should not be allowed
    regexp     : true,  // if the . should not be allowed in regexp literals
    rhino      : false, // if the Rhino environment globals should be predefined
    undef      : true,  // if variables should be declared before used
    safe       : false, // if use of some browser features should be restricted
    sidebar    : false, // if the System object should be predefined
    sub        : true,  // if all forms of subscript notation are tolerated
    white      : false, // if strict whitespace rules apply
    widget     : false, // if the Yahoo Widgets globals should be predefined
    indent: 2,
    predef: ['SC', 'require', 'sc_super', 'YES', 'NO', 'static_url', 'sc_static', 'sc_resource', 'sc_require', 'module', 'test', 'equals', 'same', 'ok', 'CoreTest', 'SproutCore', '$', 'jQuery', 'start', 'stop', 'expect', 'htmlbody']
};
  
</javascript>

<construction>
TODO: we should have a command line tool that is included in the build tools so there is a consistent standard and so all the cool kids using VI have an option.
</construction>

### Unit Tests

#### Don't break anyone else's tests

On stable builds, all of the unit tests should pass.  On development branches, if there are broken tests because of a major project that someone on the Core Team is doing, you can ignore those failures.

#### Write good tests

Writing good unit tests is something often pontificated on by seasoned developers, so rather than waste time with a long essay I'll just show some examples of good and bad unit tests:

### Consistency

 All code must be consistent with patterns found in the Application and within the Frameworks.
 example: MVC, Visitor, Statecharts don't add special functionality without good reason!


### Performance

Avoid Known Slow stuff:

 * `.observes`
 * nested run loops
 * looping
 * missing `.cacheable()`
 * code must be prove-ably fast with `SC.Benchmark`
 * keep in mind code size in kb, number of statements(IE!), doing too much on init

### Maintainability

 * Don't override private APIs
 * Be consistent and predictable
 * Make your classes extensible for other devs! (comment and modularize)
 * Use good OO practices
 * Reduce coupling between layers (parent classes should not know about their children -> looking at you SC.View)
 * Refactor, don't _hack_ -> *make code better not worse!*

### Changelog

 * March 3, 2011: initial version by [Mike Ball](credits.html#onkis)
 * March 3, 2011: minor adjustments by [Peter Wagenet](credits.html#pwagenet)
 * March 3, 2011: minor grammatical/formatting changes by [Topher Fangio](credits.html#topherfangio)
