import 'package:issual/filerw.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_driver/flutter_driver.dart';

//

void main() {
  group('FileRW Failure scenario', () {
    FlutterDriver driver;

    setUpAll(() async {
      // Connects to the app
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        // Closes the connection
        driver.close();
      }
    });

    Filerw filerw = new Filerw();
    test('FileRW Database Activities', () async {
      filerw.init();
      var todoCount = await filerw.countTodos();
      assert(todoCount == 0, 'Todo Count is $todoCount');

      Todo sampleTodo1 = new Todo(rawTodo: {
        'title': 'Todo1',
        'state': 'active',
        'desc': 'Todo Desc 1',
        'ddl': new DateTime(2018, 9, 1, 12, 0, 0),
      }, isNewTodo: true);
      await filerw.postTodo(todo: sampleTodo1);
      todoCount = await filerw.countTodos();
      assert(todoCount == 1, 'Todo Count is $todoCount');
    });
    test('postTodo() with no arguments', () {
      assert(filerw.getdb() != null);

      try {
        filerw.postTodo();
        fail('Should fail');
      } catch (_) {}
    });
  });
}
