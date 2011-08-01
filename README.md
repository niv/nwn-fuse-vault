What's this?
============

nwn-fuse-vault emulates a servervault, abstracting character load and save
into callbacks.

Usage
-----

To get started:

* install the fusefs gem

* copy config.yaml.example to config.yaml and edit to suit your needs

You will need to specify a handler that will actually do the list/load/save
for accounts and characters. If you want to write your own, have a look at
basehandler.rb.

* type ./run (preferably inside screen)

Demo handler: SQL storage of characters
---------------------------------------

There's a example handler in sequelhandler.rb. To use it, specify

    handler: sequel

in your config.yaml.

Also, you will need to set up database.yaml as shown in database.yaml.sample.

The demo handler depends on the sequel gem to be installed.

To set up the database, just run the provided migrations:

    sequel -m db/ database.yaml
