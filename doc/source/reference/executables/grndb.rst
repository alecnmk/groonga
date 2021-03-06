.. -*- rst -*-

.. highlightlang:: none

``grndb``
=========

Summary
-------

.. versionadded:: 4.0.9

``grndb`` manages a Groonga database.

Here are features:

  * Checks whether database is broken or not.
  * Recovers broken database automatically if the database is
    recoverable.

Syntax
------

``grndb`` requires command and database path::

  grndb COMMAND [OPTIONS] DATABASE_PATH

Here are available commands:

  * ``check`` - Checks whether database is broken or not.
  * ``recover`` - Recovers database.

Usage
-----

Here is an example to check the database at ``/var/lib/groonga/db/db``::

  % grndb check /var/lib/groonga/db/db

Here is an example to recover the database at ``/var/lib/groonga/db/db``::

  % grndb recover /var/lib/groonga/db/db

Commands
--------

This section describes available commands.

``check``
^^^^^^^^^

It checks an existing Groonga database. If the database is broken,
``grndb`` reports reasons and exits with non-``0`` exit status.

.. note::

   You must not use this command for opened database. If the database
   is opened, this command may report wrong result.

``check`` has some options.

``--target``
""""""""""""

.. versionadded:: 5.1.2

It specifies a check target object.

If your database is large and you know an unreliable object, this
option will help you. ``check`` need more time for large database. You
can reduce check time by ``--target`` option to reduce check target.

The check target is checked recursive. Because related objects of
unreliable object will be unreliable.

If the check target is a table, all columns of the table are also
checked recursive.

If the check target is a table and its key type is another table, the
another table is also checked recursive.

If the check target is a column and its value type is a table, the
table is also checked recursive.

If the check target is an index column, the table specified as value
type and all sources are also checked recursive.

Here is an example that checks only ``Entries`` table and its
columns::

  % grndb check --target Entries /var/lib/groonga/db/db

Here is an example that checks only ``Entries.name`` column::

  % grndb check --target Entries.name /var/lib/groonga/db/db

``--log-level``
"""""""""""""""

.. versionadded:: 7.0.4

It specifies a log level of ``grndb`` log.

Here is an example that specifies ``--log-level`` option::

  % grndb check --log-level info --log-path /var/log/groonga/grndb.log /var/lib/groonga/db/db

See :doc:`/reference/commands/log_level` to know about supported log level.

``--log-path``
""""""""""""""

.. versionadded:: 7.0.4

It specifies a path of ``grndb`` log.

Here is an example that specifies ``--log-path`` option::

  % grndb check --log-path /var/log/groonga/grndb.log /var/lib/groonga/db/db


``recover``
^^^^^^^^^^^

It recovers an existing broken Groonga database.

If the database is not broken, ``grndb`` does nothing and exits with
``0`` exit status.

If the database is broken and one or more index columns are only
broken, ``grndb`` recovers these index columns and exists with ``0``
exit status. It may take a long time for large indexed data.

If the database is broken and tables or data columns are broken,
``grndb`` reports broken reasons and exits with non-``0`` exit
status. You can know whether the database is recoverable or not by
``check`` command.

.. note::

   You must not use this command for opened database. If the database
   is opened, this command may break the database.

``recover`` has some options.

``--force-truncate``
""""""""""""""""""""

.. versionadded:: 7.0.4

It forces to truncate a corrupted database object.

Here is an example that specifies ``--force-truncate`` option::

  % grndb recover --force-truncate --log-level info --log-path /var/log/groonga/grndb.log /var/lib/groonga/db/db

When this option is specified, ``grndb`` does the followings:

* check whether there is a corrupted database object (table, column, indexes)
* truncate a corrupted database object (table, column, indexes)
* remove incremental files with .00N suffix which is created when large amount of data is loaded

``--force-truncate`` option is destructive one. Even though lock is still remained, ``grndb`` truncates a targeted corrupted database object.

After ``grndb recover`` command has finished, you need to load data
against truncated tables or columns to recreate database.

.. note::

   You must use this option only when necessary. It means that you use it when there is a mismatch between database meta information and database object files which exists actually. This options should be used when there is no other way to recover database.

``--force-lock-clear``
""""""""""""""""""""""

.. versionadded:: 7.1.1

It forces to clear lock of database, table and data column. It doesn't
clear lock of index column. If index column has lock, the index column
is recreated instead of clearing lock.

Normally, you should truncate and load data again instead of just
clearing lock. Because objects that have lock may be broken. This
option is provided only for users who know the risk that "the database
may be broken but I want to keep using it".

Here is an example that specifies ``--force-lock-clear`` option::

  % grndb recover --force-lock-clear --log-level info --log-path /var/log/groonga/grndb.log /var/lib/groonga/db/db

When this option is specified, ``grndb`` does the followings:

* check whether there are database, table or data column that have lock
* clear lock of these objects

.. note::

   You must use this option only when necessary. Because your database
   may not be recovered. The database that has objects that have lock
   may be broken or not be broken. You can keep using the database but
   Groonga may crash if the database is broken.

``--log-level``
"""""""""""""""

.. versionadded:: 7.0.4

It specifies a log level of ``grndb`` log.

Here is an example that specifies ``--log-level`` option::

  % grndb recover --log-level info --log-path /var/log/groonga/grndb.log /var/lib/groonga/db/db

See :doc:`/reference/commands/log_level` to know about supported log level.

``--log-path``
""""""""""""""

.. versionadded:: 7.0.4

It specifies a path of ``grndb`` log.

Here is an example that specifies ``--log-path`` option::

  % grndb recover --log-path /var/log/groonga/grndb.log /var/lib/groonga/db/db

