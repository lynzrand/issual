import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'filerw.dart';
import 'notifications.dart';
import 'style.dart';

class TodoCard extends StatelessWidget {
  TodoCard({Key key, this.category, this.todos, this.themeColors}) : super(key: key);

  final TodoCategory category;
  final List<Todo> todos;

  final Map<String, dynamic> themeColors;

  @override
  Widget build(BuildContext context) {
    return Theme(
      key: new Key('cardTheme#${category.name}'),
      data: Theme.of(context).copyWith(
        primaryColor: themeColors['primarySwatch'],
        accentColor: themeColors['accentColor'],
      ),
      child: new Card(
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: new Column(
          children: <Widget>[
            new Row(
              children: <Widget>[
                new Expanded(
                  child: new Container(
                    padding: EdgeInsets.all(16.0),
                    child: new Text(
                      category.name.toUpperCase(),
                      style: Theme.of(context).textTheme.title.apply(
                            color: (themeColors['primarySwatch'] as MaterialColor).shade800,
                          ),
                    ),
                  ),
                ),
                new IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () =>
                      TodoEditNotification(category: category, newTodo: true).dispatch(context),
                ),
                new PopupMenuButton(
                  icon: Icon(Icons.more_vert),
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        child: Text('Delete'),
                      ),
                    ];
                  },
                ),
              ],
            ),
            new Column(
              children: List.generate(todos == null ? 1 : todos.length, (int index) {
                if (todos == null)
                  return new Container(
                    height: 96.0,
                    alignment: Alignment.center,
                    child: new Text('This category currently has no Todos'),
                  );
                else
                  return new TodoListItem(todos[index], index, key: Key(todos[index].id));
              }),
            ),
            // new ButtonBar(
            //   children: <Widget>[
            //     // new IconButton(
            //     //   icon: new Icon(Icons.add),
            //     //   onPressed: null,
            //     // )
            //     new IconButton(
            //       icon: Icon(Icons.add),
            //       onPressed: () => TodoEditNotification(rawTodo: {'category': title}, newTodo: true)
            //           .dispatch(context),
            //     )
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}

class TodoListItem extends StatefulWidget {
  TodoListItem(final this.todo, this.index, {Key key}) : super(key: key);

  // TODO: move this to filerw.dart/todo

  final Todo todo;
  final int index;
  @override
  State<StatefulWidget> createState() {
    return new _TodoListItemState(todo.state, todo.id);
  }
}

class _TodoListItemState extends State<TodoListItem> {
  // TodoState state;
  _TodoListItemState(this.state, this.id);
  String state;
  final String id;

  void flipState() {
    setState(() {
      switch (state) {
        case 'open':
          state = 'active';
          break;
        case 'closed':
        case 'canceled':
          state = 'open';
          break;
        case 'active':
        case 'pending':
        default:
          state = 'closed';
          break;
      }
    });

    TodoStateChangeNotification(
      id: widget.todo.id,
      stateChange: TodoStateChangeType.flip,
      data: {'todo': widget.todo, 'index': widget.index, 'state': state},
    ).dispatch(context);
  }

  @override
  Widget build(BuildContext context) {
    return new Slidable(
      key: new Key('slidableTodoItem$id'),
      delegate: SlidableDrawerDelegate(),
      slideToDismissDelegate: new SlideToDismissDrawerDelegate(
        dismissThresholds: {SlideActionType.primary: -0.5, SlideActionType.secondary: 1.0},
        onWillDismiss: (type) {
          flipState();
          return false;
        },
        closeOnCanceled: true,
      ),
      secondaryActions: <Widget>[
        SlideAction(
          // color: Colors.red,
          child: new Center(
              child: Icon(
            Icons.edit,
            // color: Colors.white,
          )),
          onTap: () {
            TodoEditNotification(rawTodo: widget.todo.toMap(), category: widget.todo.category)
                .dispatch(context);
          },
        ),
        SlideAction(
          color: Colors.red,
          child: new Center(
              child: Icon(
            Icons.delete,
            color: Colors.white,
          )),
          onTap: () {
            TodoStateChangeNotification(
                id: widget.todo.id,
                stateChange: TodoStateChangeType.remove,
                data: {'todo': widget.todo, 'index': widget.index}).dispatch(context);
          },
        ),
      ],
      actions: <Widget>[
        SlideAction(
          color: Theme.of(context).primaryColor,
          child: new Center(
              child: Icon(
            Icons.check,
            color: Colors.white,
          )),
          onTap: () => flipState(),
        ),
      ],
      child: Material(
        color: Theme.of(context).cardColor,
        child: InkWell(
          splashColor: IssualColors.darkColorRipple,
          // TODO: onTap: emit a notification up the tree!
          onTap: () {
            TodoStateChangeNotification(
              id: widget.todo.id,
              stateChange: TodoStateChangeType.view,
              data: widget.todo.title,
            ).dispatch(context);
          },
          child: new Row(
            children: <Widget>[
              new IconButton(
                icon: new Icon(
                  IssualMisc.stateIcons[state],
                  color: IssualMisc.getColorForState(context, state),
                ),
                onPressed: () => flipState(),
                tooltip: 'Flip Todo state',
              ),
              new Expanded(
                child: new Hero(
                  tag: this.widget.todo.id + 'title',
                  child: new Text(
                    this.widget.todo.title ?? '#${this.widget.todo.id}',
                    style: IssualMisc.getTodoTextStyle(context, state),
                  ),
                ),
              ),
              // new PopupMenuButton(
              //   icon: new Icon(Icons.more_horiz),
              //   // itemBuilder: ,
              //   itemBuilder: (BuildContext context) {
              //     return [
              //       PopupMenuItem(
              //         value: 'remove',
              //         child:
              //             // new Row(children: [new Icon(Icons.delete),
              //             Text('Remove'),
              //         //  ]),
              //       ),
              //       PopupMenuItem(
              //         value: 'edit',
              //         child:
              //             // new Row(children: [new Icon(Icons.edit),
              //             new Text('Edit'),
              //         //  ]),
              //       )
              //     ];
              //   },
              //   onSelected: (dynamic item) {
              //     switch (item as String) {
              //       case 'remove':
              //         TodoStateChangeNotification(
              //             id: widget.todo.id,
              //             stateChange: TodoStateChangeType.remove,
              //             data: {'todo': widget.todo, 'index': widget.index}).dispatch(context);
              //         break;
              //       case 'edit':
              //         TodoEditNotification(rawTodo: widget.todo.toMap()).dispatch(context);
              //         break;
              //     }
              //   },
              // )
            ],
          ),
        ),
      ),
    );
  }
}
