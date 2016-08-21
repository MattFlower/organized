# What Is Organized?

Organized is designed to allow you to keep notes, a schedule, and todo list
inside of Atom.

![Organized Screenshot](https://raw.githubusercontent.com/MattFlower/organized/master/screenshots/0_0_1.gif)

Right now, we're in the early stages of Organized, but join us now and watch
us get better.  I think we've already have a pretty functional outliner and
todo lists.  

# Features
* Outlining
  * Indent or Unindent with tab and shift-tab
  * Automatically create stars if you've been outlining and you press enter.
  * Write more text for the same star on a new line if you press shift-enter
  * "*", "-", and "+" characters supported for outlining
* Support todo items
  * Highlighting of [TODO]/[COMPLETED] tags
  * Ctrl-Shift-T for toggling todo items from [TODO] to [COMPLETED] to blank.
* Highlighting of org-mode style Metadata headers

# What Do I Want to Build
* Complete compatibility with existing org-mode documents
* Syntax coloring for code blocks
* Ability to execute code blocks inline
* Nice looking panes that can show you your todos and agendas across multiple organized documents
* Export to pdf, html, etc

# Learning the Basics of Organized
At the most basic level, Organized is an outlining / note taking tool.  You can
use either of the two major styles to create an outline:

    * Level 1
      * One way to express index level 2
        * One way to express index level 3

    * Level 1
    ** An alternate way to express index level 2
    *** An alternate way to express index level 3

You can also use alternate characters too.  If you use whitespace to establish
your indent level, you can mix them:

    - Level 1
      * Level 2
        - Level 3

    - Level 1
    -- Level 2
    --- Level 3

    - Level 1
    -* <=== This is not valid

If you feel like you need to add a TODO, press ctrl-shift-t to do it:

    * [TODO] Some important task

When you are done with your task, press ctrl-shift-t again to mark it as completed.

    * [COMPLETED] Some task I'm done with

If you didn't mean to mark it as a TODO, pressing ctrl-shift-t a final time
will make it disappear.

You might want to organize your notes a bit.  You can do that with markdown-style headers (a # character, a space, and some text):

    # This is a heading
    * Here are some notes
      * More specific notes

    ## A subheading
    * With some more notes

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
