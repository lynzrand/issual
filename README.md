![iL Logo](docs/res/iL_header.png)

# iL

iL (codename "Issual") is purely a Todo manager with some handy features. Its
name "iL" does not hold any special meanings.

iL is a Course Design work of the "Hands-on With Software Design" course in
BUAA. Not sure if I'll continue to work on this after the course is done.

This project is not tested with iOS devices, and should only be run on Android.
If _someone_ would like to test and release an iOS version of it, PLZ DO THAT!

## Features

- Regular todo items managing
- Categorizing todo items
- Adding multiple state to items. Currently avaliable ones are: Open, Closed,
  Active, Pending, Canceled. User addition Soon™.

## Download

[Release Page](https://github.com/01010101lzy/issual/releases).

**Current version: Beta 0.3.2 "Saika"**

## Known Issues

- There is no visible delete button for single todos
- Delete button for Categories do not work
- Todos cannot migrate from category to category
- No actrual tag support is avaliable

## Changelog

### Alpha 0.3.1 "Megumin"

- FIXED unable to add todo inside category
- FIXED wrong type return by Filerw/Filerw.getRecentTodo

### Alpha 0.3.0 "Asahi"

- ADD category support for todos

### Older versions are not logged

## Comparation with other todolists

## License

MIT © 2018 Rynco Li.

## Usage

```sh
# To build, add your own key and run
$ flutter build apk

# To test, run
$ flutter run

# To test release version, run
$ flutter run --release
```

For more documentation about this freamwork see [Flutter's website](https://flutter.io).

More documentation on this project at [docs/readme.md]().
