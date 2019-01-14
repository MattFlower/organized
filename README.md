# What Is Organized?

Organized is designed to allow you to keep notes, a schedule, and todo list
inside of Atom.

![Organized Screenshot](https://raw.githubusercontent.com/MattFlower/organized/master/screenshots/0_6_0.gif)

Right now, we're in the early stages of Organized, but join us now and watch
us get better.

# Features
* Outlining
  * Indent or Unindent with tab and shift-tab
  * Automatically create stars if you've been outlining and you press enter.
  * Write more text for the same star on a new line if you press shift-enter
  * "*", "-", and "+" characters supported for outlining
  * Support numbered bullets
* Visibility cycling
  * Ctrl-i v will cycle between:
    1. Hiding all indented content for the current star
    2. Only showing the top level items under the current star, their children will be hidden
    3. Showing all content
  * Ctrl-Shift-i v will do the same cycling described above, except it will do it for all content
* Support todo items
  * Highlighting of [TODO]/[DONE] tags
  * Ctrl-Shift-T for toggling todo items from [TODO] to [DONE] to blank.
  * Todo items can be marked with a priority of A to E.  This will impact their sorting in the sidebar. (The default
    level is C if the items aren't marked.)
  * Highlighting for CLOSED, DEADLINE, and SCHEDULED tags.  DEADLINE and SCHEDULED items will show up in the sidebar.
  * When transitioning from TODO to DONE, automatically add a property recording when the TODO was closed
* Code blocks
  * Syntax highlighting for code blocks in c, coffeescript, c++, css, golang, html, java,
    javascript, less, objective c, objective c++, python, php, r, ruby, shell scripts (generic), and sql.
  * Execution for c, c++, coffeescript, golang, java, javascript, objective-c, perl, php, python, r, Ruby, PSQL, and shell
    scripts.  Put your cursor in your code block and press [Ctrl-` x] to execute code.  Output from
    code will appear in a notification by default, or create resultblock:

    ~~~~
    ```result
    ```
    ~~~~

    and the output will appear there.
  * Early support for code execution in C, C++, Java, Golang, R, and Objective-C.  You cannot set any libraries in
    those languages yet, which may reduce their effectively a bit.
  * Results can be displayed as an information popup or as a separate section in
  * about PSQL.
    Psql needs a host, user, and password.  This is automatically discovered from a comment put anywhere in the file before the code block.  The block will use the closest configuration, so you can have more than one.  The format of the comment should be exactly (database is optional):

    ```
    [comment]: # psql:<host>:<user>:<database>
    ```

    So, if you were using the Docker postgres image, it would look like this:

    ```
    [comment]: # psql:localhost:postgres:example:my_database
    ```


    ** Note: you also need a .pgpass file in your home directory, or disable passwords altogether to make this work.  This is a standard postgres way to handle passwords.  [PG docs](https://www.postgresql.org/docs/9.3/libpq-pgpass.html).  Mine looks like this to continue the docker example:

    ```bash
    #hostname:port:database:username:password
    *:*:*:postgres:example
    ```

* Sidebar
  * New sidebar shows all the todo files across the .org files in the open projects.  Settings allow you
    to always check additional projects.  Todos can be closed on jumped to with a single click
* Integrates with the [tool-bar](https://atom.io/packages/tool-bar) package to get buttons for easy access
  to common actions.
* Tables
  * Create an ascii-based table
  * Rather than writing closing table blocks, use "Ctrl-- C" to automatically close them.
* Highlighting of org-mode style Metadata headers, SCHEDULED properties, links, and
  Org-mode-style tags (:tagname:)

# How to Use Organized?

Most of the instructions on how to use org-mode consist of two things:

1. This document - it has descriptions for all the features and a list of keystrokes
2. Sample files - This will show you how org mode looks in action.  See:
  * [Code Blocks]([CHANGELOG.org](https://raw.githubusercontent.com/MattFlower/organized/master/samples/Code.org)),
  * [Sample Editing](https://raw.githubusercontent.com/MattFlower/organized/master/samples/SAMPLE.org)
  * [Tables](https://raw.githubusercontent.com/MattFlower/organized/master/samples/Code.org)

I'll eventualy get to writing a proper manual, time permitting

# Current Keystrokes
Here are the keystrokes I have mapped as of today:

| Keystroke      | What it does                                                        |
| ---------------| ------------------------------------------------------------------- |
| ctrl-shift-t   | Toggles a special identifier at the beginning of a line that will mark that line as a TODO.  This will make it show up in the sidebar |
| ctrl-enter     | If you are on a star line, move to the next line without creating a star |
| ctrl-i a       | Remove the current subtree from your file and put it into a file named {current-filename}.org_archive.  These files are still in org mode, but aren't indexed so they won't show up in the sidebar.|
| ctrl-i t       | Insert the current date/time in ISO-8601 format                     |
| ctrl-i /       | Insert the current date in ISO-8601 format                          |
| ctrl-i l       | Make a link.  If there is no selection, we'll insert []().  If there is a selection, I'll try to intelligently decide whether you are selecting a url or text and put it in the brackets or parentheses as appropriate.|
| ctrl-i s       | Add a schedule tag for a star.  This defaults to today, there is no mechanism to choose the date other than editing it yourself.  If you want to add a time, you can use ISO-8601 time <2016-01-01T14:00:00>  or org-mode style time <2016-01-01 Fri 14:00:00>.  Either one should work. |
| ctrl-i v       | Cycle visibility between only showing the next level stars below the current star, showing the next two levels, or showing everything.|
| ctrl-shift-i v | Cycle global visibility.  Like the above except that it applies to everything in the whole file. |
| ctrl-` x       | Execute the current code block                                      |
| alt-shift-up   | Increase the priority of the current block.  A is the highest priority, E is the lowest.  This will show up in the todos as some arrows. |
| alt-shift-down | Decrease priority.                                                  |

# What's New?

* 0.8.1 (Released 2017-10-30)
  * Fixed some bugs released to having organized in "Only show top level stars" mode when opening new files.
  * Closes issues #26, #27, and #28.
* 0.8.0 (Release 2017-10-27)
  * Fixed toggling of TODO tags if you don't use brackets.
  * Fixed indenting if you used stacked star types
  * Added new key command (ctrl-i v) to cycle visibility of the current subtree.
  * Added new key command (ctrl-shift-i v) to cycle visibility of the whole file
  * Add setting to control visibility when you first load a file.  Default is to hide nothing.
  * Added the ability to automatically add the CLOSED property when closing a TODO
  * Don't show TODO or DONE in agenda items
  * Always show the contents of the current file in the sidebar if the current file is an organized file.
* 0.7.2 (Release 2017-09-21)
  * Fixed issue #2 which was preventing the toolbar plugin from being installed when it wasn't already installed.
  * Newline on a letter was emitting the wrong behavior
  * Icons on the sidebar all appears as squares if you didn't choose to install the tool-bar.  Now they do regardless
    of whether the toolbar is enabled
  * Fix error in grammar resulting in all two letter works at the beginning of a line appearing as a star (grammar
    requires double slash to escape)
* 0.7.0 (Released 2017-09-20)
  * Close Issue #17: TODO tags without brackets not shown in sidebar
  * Close Issue #20: Uncaught TypeError: Cannot read property 'size' of undefined
  * If agenda item items are all day, show them as "ALL DAY" in the agenda rather than "12:00 AM"
  * Single letters (upper or lowercase) can be used as a "star"
  * Got rid of excessive "files" logging message

Please see the [CHANGELOG.org](https://raw.githubusercontent.com/MattFlower/organized/master/CHANGELOG.org)
for full details of recent changes.


# What Do I Want to Build
* Complete compatibility with existing org-mode documents
* Syntax coloring for code blocks (Done)
* Ability to execute code blocks inline (Done)
* Nice looking panes that can show you your todos and agendas across multiple organized documents (In progress)
* Export to pdf, html, etc

# Learning the Basics of Organized
At the most basic level, Organized is an outlining / note taking tool.  You can
use either of the two major styles to create an outline:

```
    * Level 1
      * One way to express index level 2
        * One way to express index level 3

    * Level 1
    ** An alternate way to express index level 2
    *** An alternate way to express index level 3
```

You can also use alternate characters too.  If you use whitespace to establish
your indent level, you can mix them:

```
    - Level 1
      * Level 2
        - Level 3

    - Level 1
    -- Level 2
    --- Level 3

    - Level 1
    -* <=== This is not valid
```

If you feel like you need to add a TODO, press ctrl-shift-t to do it:

```
    * [TODO] Some important task
```

When you are done with your task, press ctrl-shift-t again to mark it as completed.

```
    * [DONE] Some task I'm done with
```

If you didn't mean to mark it as a TODO, pressing ctrl-shift-t a final time
will make it disappear.

You might want to organize your notes a bit.  You can do that with markdown-style headers (a # character, a space, and some text):

```
    # This is a heading
    * Here are some notes
      * More specific notes

    ## A subheading
    * With some more notes
```

If you need to write some source code, you can do that too:

~~~~
    ```java
    public static void main(String[] args) {
      System.out.println("Hello, World");
    }
    ```
~~~~

# Why Did I Write Organized?
I designed Organized in response to a personal itch.  I've long been a user
of note taking software (plain text, notebooks, Evernote, OneNote, etc) and
I've long been a user of todo applications (Outlook, Things, Clear, Todoist).

One day I discovered org-mode, despite the fact I'd been a long-time emacs user.
I absolutely loved the concept -- in my mind, todo items should live inside your
notes.  OneNote almost had this feature, but unfortunately they didn't
implement a good way to roll them up in the Mac version.  So you've got todos
floating around with no good way to coalesce them.  (I think this might work
if you are using Outlook, but I'm not with you there anymore).  I was totally
lured in by the ability to both style source code inside your notes AND to
actually run them (wow!).  Once I found tables that could execute formulas,
I know this was a generation beyond what I had been using.  (From a mode that
has been around forever! nonetheless).

After using org-mode for a few weeks, I found myself craving something more:

* It's Emacs.  You can make almost anything happen (and I have done a lot) but
  some things are just clunky.  Multi-line cursors are important to me, but I
  still can't find an implementation I like in Emacs.  I could write it, but
  that is just one of many problems.
* I totally get the mini-buffer in Emacs.  I've made it better (for me) using
  that vertical mode thing, but in the end, I really just want normal pop downs
  and popups.  I'm not using my organizer on remote machines, so this isn't an
  issue.
* I want a real ui sometimes.  I want nice colors and checkboxes for my todos.
  I want a fancy looking calendar.  I can kinda have this in Emacs, but it just
  isn't pretty enough.  Yep, this is shallow of me.  I get it.
* I can install pdflatex/texlive, but really I just want it to work.  Also, with
  no offense meant to latex, I feel like a style upgrade is needed.  I probably
  could have rolled that myself too.

I've been told that immitation is flattery.  If you have contributed on org-mode
and you are fuming at my suggestions, please know I hold you in the highest
regard.  Really!

# Contributions
Contributions of source code or bugs are welcome!  Please use [Github](https://github.com/MattFlower/organized) to submit
issues or pull requests.

# License
This project has been released under the MIT license.  Please see the
LICENSE.md file for more details.
