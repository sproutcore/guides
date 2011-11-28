## Advanced Properties

After reading this guide, you will be able to make full use of properties in your models, views, and controllers, including:

 * simple default values
 * default values the must be unique to each instance
 * whether or not to cache properties
 * properties with both getters and setters
 * depending on other properties within the same model
 * depending on properties of global objects

You will learn all of this through a series of reciepes, all used in a fictitious blogging application called Blogg.

endprologue.

### Simple Default Values

#### Problem

You want all instances of a class to have the same default value for a property. Here, we want all new comments to have a default name of "Anonymous Coward."

#### Recipe

Simply declare the property the default value in your subclass of `SC.Object`:

    Blogg.Comment = SC.Object.extend({
      author: "Anonymous Coward"
    });

    comment = Blogg.Commment.create({});
    comment.get("author"); => "Anonymous Coward"

NOTE: Everything that is being done here with classes can also be done with instances. If you have a global model (such as the current user) or a global controller (such as the nnew-comment controller), you do the same things with the arguments to `create` as `extend`.

### Per-Instance Default Values

#### Problem

You want each instance of a class to have a *unique instance* of a default value for a property.

#### Recipe

Declare the property with a function that returns a new instance of the default value. Here, we want all blog posts to have a `newComment` property that is an instance of `Blogg.Comment`, but we want to ensure that different posts have unique instances.

    Blogg.Post = SC.Object.extend({
      // The comment to be added by the reader
      newComment: function() {
        return Blogg.Comment.create({})
      }.property().cacheable()
    });

    postOne = Blogg.Post.create({}),
    postTwo = Blogg.Post.create({});
    postOne.get("comment") === postTwo.get("comment"); // false
    postOne.getPath("comment.author"); // "Anonymous Coward"

### `cacheable()`

Did you notice that `cacheable()` call that snuck in there? When a property is `cacheable`, Sproutcore does two things. First, it ensures that the function you provide is only called once&hellip; at least until the cache is invalidated, which happens when the property is set or when one of its bound dependencies (see below) changes. This is important if the function to calculate the property value is expensive. Second, if your property has a setter version (see below), Sproutcore takes care of saving off the value and returning it on later invocations. This means you don't have to worry about setting the property anywhere.

TIP: For now, you can use the following rule: make the property cacheable unless you need it to be recalculated every time it is requested.

    var cacheTest = SC.Object.create({
      uncachedProperty: function() {
        this.uncachedCallCount = this.uncachedCallCount || 0;
        this.uncachedCallCount = this.uncachedCallCount + 1;
        return this.uncachedCallCount;
      }.property(),

      cachedProperty: function() {
        this.cachedCallCount = this.cachedCallCount || 0;
        this.cachedCallCount = this.cachedCallCount + 1;
        return this.cachedCallCount;
      }.property().cacheable(),
    });

    cacheTest.get('uncachedProperty'); // 1
    cacheTest.get('uncachedProperty'); // 2
    cacheTest.get('cachedProperty'); // 1
    cacheTest.get('cachedProperty'); // 1

### Coercing Setters

#### Problem

You have a property that needs to be in a certain format or needs to be of a specific type, but you want to be very permissive in the values you accept and do the coercion yourself. Here, we're going to allow the post's `createdAt` timestamp to be set with a `String`, but we want it to always be a `Date`.

#### Solution

Declare the property with a function that takes two arguments, the *second* of which is the new value to be set. Return the coerced value in your function. Use `cacheable()` so that Sproutcore handles the actual getting and setting for you.

    Blogg.Post = SC.Object.extend({
      createdAt: function(propertyName, newValue) {
        if (arguments.length > 1) {
          // if used as a setter, return the coerced value:
          return newValue instanceof Date ? newValue : new Date(newValue);
        } {
          // else, return a default value of _now_
          return new Date();
        }
      }.property().cacheable()
    });

    var post = Blogg.Post.create({});
    post.get("createdAt"); // Wed Aug 31 2011 09:43:25 GMT-0700 (PDT)
    post.set("createdAt", "2011-07-14");
    post.get("createdAt"); // Thu Jul 14 2011 00:00:00 GMT-0700 (PDT)

NOTE: If the property is cacheable and your function doesn't return anything (either by not having a `return` statement or by doing `return;`), Sproutcore will use the passed `newValue` as the value to set.

TIP: the *first* argument is the property name itself. We don't have any use for that here since we know it is "createdAt", but it is useful if you want to use the same function as the getter and/or setter for multiple properties.

### Loading Property Values Asynchronously

#### Problem

You have a property that must be computed asynchronously, perhaps via an AJAX call. Here, we want `Blogg.currentUser` to be fetched as soon as the page loads.

#### Solution

Since Sproutcore will notify observers when a property changes, you can simply initiate the asynchronous call and then return nothing. When the call resolves, set the value and observers will be notified.

    Blogg = SC.Application.create({

      currentUser: function() {
        $.getJSON("/users/current")
         .done(function(json) {
           Blogg.set("currentUser", Blogg.Person.create(json));
         });
      }

    });

    Blogg.get("currentUser"); // undefined
    // wait a while
    Blogg.get("currentUser"); // Person ...

### Computing from Internal Properties

#### Problem

You want to compute a property from other properties on the same object and have the computed property update every time the dependent properties do. Here, we want to compute a post's `slug` from its `id` and `title`.

#### Solution

Declare the property as a function that returns the computed value. Call `property()` with the list of dependent properties and `cacheable()` if applicable.

    Blogg.Post = SC.Object.extend({
      slug: function() {
        var id, title = this.get("id"), this.get("title");
        if (!id) { return null; }
        title = title && title.replace(/[^a-zA-Z0-9_-]+/g, "-");
        return [id, title].join("-");
      }.property("id", "title").cacheable()
    });

    var post = Blogg.Post.create({
      id: 436,
      title: "My favorite cheeses"
    });
    post.get("slug"); // "436-My-favorite-cheeses"

TIP: If the property needs to be calculated from a property on an associated object, you can use a nested property dependency as follows:

    Blogg.Post = SC.Object.extend({
      author: function() {
        return Blogg.Person.create({})
      }.property().cacheable(),

      authorName: function() {
        return this.getPath("author.name");
      }.property("author.name").cacheable()
    });

### Computing from External Properties

#### Problem

You want to compute a property from properties in some global object that you cannot reference directly as a property of the object in question. Here, we want posts to have a minutesSincePosted that continually updates while a user is looking at the blog post.

#### Solution

Declare the global property as a property on a globally-accessible instance of `SC.Object`. Declare a "*Binding" on the dependent object that is bound to the global property. Declare the computed property as being dependant on the "*Binding" property.

    var Blogg = SC.Application.create({
      currentTime: function() {
        return new Date();
      }.property().cacheable()
    });

    // update Blogg.currentTime every minute:
    Blogg.set("tick", setInterval(function() {
      Blogg.set("currentTime", new Date());
    }, 60000));

    Blogg.Post = SC.Object.extend({

      currentTimeBinding: SC.Binding.oneWay("Blogg.currentTime"),

      minutesSincePosted: function() {
        var createdAt = this.get("createdAt"),
            now       = this.get("currentTime");
        if (!createdAt || !now) { return null; }
        return (now.getTime() - createdAt.getTime()) / 60000;
      }.property("currentTimeBinding", "createdAt").cacheable()

    });

NOTE: It's important that `Blogg.currentTime` is declared as a `function(){...}.property` and not a primitive or object. If you use `currentTime: new Date()`, Sproutcore will not be able to set up the property bindings.

TIP: For more information about bindings, see the "SC.Binding documentation":http://docs.sproutcore20.com/#doc=SC.Binding&src=false

### Changelog

* August 31, 2011: initial version by "James A. Rosen":credits.html#jamesarosen
