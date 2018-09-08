# Structure of this project

## Front End

- `main.dart`

  - `IssualHome` The main entry point
  - `MyHomePage` Mainpage
    - `____Handler()` Handles different kind of notification
    - `_buildTodoCard()` Builds Todo Card from data
  - `IssualAppBar`
  - `IssualFAB` _deprecated_
  - `IssualNewCategoryButton`
  - `IssualNewCategoryDialog`
  - `IssualNewCategoryColorSelector`
  - `IssualDebugInfoCard`

- `todo_widgets.dart` Widgets to display Todo

  - `TodoCard`
  - `TodoListItem`

- `todo_view.dart`

  - `IssualTodoView` Detailed view of single todos
  - `IssualTodoEditView` Editing page

- `search_screen.dart` _unfinished_

- `settings.dart` _unfinished_ Settings Page

## Back End

- `filerw.dart`

  - `Todo` Base class for Todo items
  - `TodoCategory` Base class for Todo Categories
  - `Filerw` Handles ALL actions about database

## Utilities

- `style.dart` Defines styles in the program

  - `IssualColors` Defines colors and themes
  - `IssualTransitions` Defines transitions
  - `IssualMisc` Defines some miscanellous functions and datas
    - `getReadableTimeRepresentation()` generates text representations of time. _e.g. "Just now", "3 minutes ago" and "at 1970-1-1."_
    - `getColorForState()` selects the corresponding color in a theme for a todo state.
    - `getColorForStateDesaturated()` does basically the same thing, but uses only grays.
    - `getTodoTextStyle()` generates text styles for a todo state
    - `stateIcons` shows the corresponding icon for each todo state

- `notifications.dart` defines notification types for bubbling data up the widget tree

# How iL manages data

iL uses SQLite to store data. It has five tables to store data for todo items. They are stored in the following way (* means PRIMARY KEY):

### TABLE Todolist

Stores basic information of todo items

| Row   | type    | Description                       |
| ----- | ------- | --------------------------------- |
| id*   | TEXT    | A 26-letter unique identifier [1] |
| title | TEXT    | Title                             |
| state | TEXT    | State                             |
| desc  | TEXT    | Description                       |
| ddl   | INTEGER | Deadline time (not implemented)   |
| tags  | TEXT    | **DEPRECATED** Tags               |

### TABLE Categories

Stores all categories.

| Row   | Type    | Description                    |
| ----- | ------- | ------------------------------ |
| id*   | INTEGER | Identifier. [2] AUTOINCREMENT. |
| name  | TEXT    | Category. UNIQUE.              |
| color | TEXT    | Theme color of Category.       |

### TABLE Tags

Stores all tags.

| Row | Type    | Description                    |
| --- | ------- | ------------------------------ |
| id* | INTEGER | Identifier. [3] AUTOINCREMENT. |
| tag | TEXT    | Category. UNIQUE.              |

### Table TodoCategoryJoin

Links Todo to Category

| Row        | Type    | Description                |
| ---------- | ------- | -------------------------- |
| id*        | INTEGER | Identifier. AUTOINCREMENT. |
| todoId     | TEXT    | Todo ID in [1]             |
| categoryId | INTEGER | Category ID in [2]         |

### Table TodoTagsJoin

Links Todo to Tags

| Row    | Type    | Description                |
| ------ | ------- | -------------------------- |
| id*    | INTEGER | Identifier. AUTOINCREMENT. |
| todoId | TEXT    | Todo ID in [1]             |
| tagId  | INTEGER | Tag ID in [3]              |

[1] Storing a [Ulid][].

[Ulid]: https://github.com/ulid/spec

# How iL deals with data changes

## Deep in large widget trees

iL uses Notifications to handle data change requests in deep widget trees, like in Mainpage, where passing the `Filerw` object is impractical. A `Notification` will be dispatched from the widget and bubble up the widget tree, and be captured by a `NotificationListener` near the root.

It looks like this in code:

```dart
class SomeCustomViewState extends State<SomeCustomView>{
  bool notificationHandler(Notification t){
    if(t is SomeNotification){
      // ...
      return true;
    }
  }

  @override
  Widget build(BuildContext context){
    return new NotificationListener(
      onNotification: notificationHandler,
      child: new Scaffold(
        //...
      ),
    );
  }
}

class SomeButtonHidingDeep extends StatelessWidget{
  @override
  build(BuildContext context){
    return new SomeButton(
      onPressed: () => SomeNotification.dispatch(context),
      // ...
    );
  }
}
```


