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
* Support todo items
  * Highlighting of [TODO]/[DONE] tags
  * Ctrl-Shift-T for toggling todo items from [TODO] to [DONE] to blank.
  * Todo items can be marked with a priority of A to E.  This will impact their sorting in the sidebar. (The default
    level is C if the items aren't marked.)
  * Highlighting for CLOSED, DEADLINE, and SCHEDULED tags.  DEADLINE and SCHEDULED items will show up in the sidebar.
* Code blocks
  * Syntax highlighting for code blocks in c, coffeescript, c++, css, golang, html, java,
    javascript, less, objective c, objective c++, python, php, r, ruby, shell scripts (generic), and sql.
  * Execution for c, c++, coffeescript, golang, java, javascript, objective-c, perl, php, python, r, and shell
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
    your notes for future reference.
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


# What's New?

* 0.6.8 (Released 2017-09-18)
  * Re-write of code that finds agendas and todo items.  This should fix several problems:
    * Files should not longer be open multiple times per scan
    * Soft-linked files, permissions errors, or other problems relating to opening files should be eliminated
    * Close Issue #4 - Sidebar not working
  * Fixed bug that duplicates agenda and todo items if you have specified a predefined directory and you have
    that directory open as a project.
  * Try to eliminate duplicates which arise if you have a predefined search directory and you open it's parent
    directory as a project.
* 0.6.7 (Released 2017-05-09)
  * Fixed bug that caused sidebar to be refreshed several times during startup.  This
    slowed down startup and caused duplicates to show up in the agenda and todo items.
  * Removed command that was accidentally included and not yet implemented.
* 0.6.3-0.6.6 (Release 2017-03-23)
  * Implemented syntax coloring for todo priorities
  * Todo Items are now sorted according to priority.  (Default priority is "C", range is A-E)
  * Added keystrokes option-shift-up and option-shift-down to change priority of current item.  These should be
    alt-shift-up and alt-shift-down on windows.
  * Priority items in todo items
  * Added syntax highlighting for deadlines
  * Added keystrokes (ctrl-i d) to add a deadline.  Existing "insert date" functionality has been remapped to
    (ctrl-i /)
  * Deadlines are treated like schedule items (for now) in agendas

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
