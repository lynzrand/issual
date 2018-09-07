# Introduction

iL is a simple Todo manager application which can also double as a note app. It features a clean interface for Todo managing, as well as some handy features.

iL basically follows Material Design on its user interface design.

## User Interface

The user interface is pretty intuitive. The following are some screenshots from one of our development builds.

### Main Screen

![Main Screen](/docs/res/main_screen.png)

### Quick Actions

![Slidable Items](/docs/res/slidable_item.png)

### View and Edit Screens

![View&Edit Screen](/docs/res/view_and_edit_screen.png)

### Creating a new Category

![New Category](/docs/res/adding_category.png)

## Notes

### Flipping states

iL currently uses **three** states in todo items instead of two in regular todo managers. Clicking on status indicator or swiping to the right in todo list cycles the state in `Open -> Active -> Closed` way.

### Markdown in description

Yeah, you heard it right, just _this Markdown_ does not support HTML snippets. And it's not written by me.

Markdown formats it supports:

- _Italic_ text ( `*Italic*` or `_italic_` )
- **Bold** text ( `**Bold**` or `__Bold__` )
- Links ( `[text](link)` )
- Images( `![desc](image)`, **web images only**)
- `code`
- Code blocks
- Bulleted List
- Numbered List
- Separator line
