## State Charts

After reading this guide, you will be able to use state charts to cleanly
manage state in your application.

endprologue.

### Terminology

 * `SC.StateManager` -- a state machine containing any number of
   mutually-exclusive states.
 * `SC.State` -- a state within a state manager
 * `SC.ViewState` -- a subclass of `State` that is attached to a view and
   automatically renders the view on enter and removes it on exit

### Best Practices

While state managers and states are `SC.Object`s, it is best to be very
restrictive in the ways you interact with them from outside. Obeying the
following rules will make it easier to keep states consistent and to
refactor and change states as your business logic changes.

#### Use Actions

Make *actions* (functions) on the state manager and call those from the
outside; don't call `goToState` directly.

    // Good
    Blogg.States = SC.StateManager.create({
      editPost: function(post) {
        Blogg.postController.set('post', post);
        this.goToState('post.editing');
      },
      ...
    });

    // Bad
    Blogg.postController.set('post', aPost);
    Blogg.States.goToState('post.editing');

#### Avoid `set`

Avoid setting properties on state managers and states, especially from
outside the state manager. Setting objects (like the `currentPost`) makes
states harder keep consistent. Instead, pass the object into an action
and have the state machine set it on some controller.

#### Call Actions only on the State Manager

The outside world (routes, controllers, etc.) should call actions only
on the state manager. The state manager can delegate that action to its states
if the logic is complex.

### Patterns

#### The `currentState` property

This pattern is useful when you want to change the appearance of some UI
element depending on the current state. To do so, add a property to a
state and bind to it using `currentState`:

    Blogg.States = SC.StateManager.create({
      post: SC.State.create({
        edit: SC.State.create({
          draft: SC.State.create({
            isDraft: true
          })
        })
      })
    });

    {{#view classBinding="Blogg.States.currentState.isDraft"}}
      ...
      <aside class="draft-notice">This post is a draft.</aside>
    {{/view}}

    .is-draft               { background: yellow; }
              .draft-notice { display: none; }
    .is-draft .draft-notice { display: block; }

Whenever `Blogg.States` is in the `post.edit.draft` state, that view
will have the `is-draft` class, meaning the `aside` will show up and the
`div` will have a yellow background.

