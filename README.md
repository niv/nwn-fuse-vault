What's this?
============

nwn-fuse-vault emulates a servervault, abstracting character load and save
into callbacks.

Please note that this is BETA quality and just may eat your characters.
Pay close attention to the charset in your database configuration.

*This thing requires customisation on your part to have it work.*

Usage
-----

To get started:

* have ruby 1.9.3 or newer installed

* for sqlite: bundle install --deployment --without mysql pg
* for postgres:  bundle install --deployment --without mysql sqlite
* for mysql: bundle install --deployment --without pg sqlite

* copy config.yaml.example to config.yaml and edit to suit your needs

You will need to specify a handler that will actually do the list/load/save
for accounts and characters. If you want to write your own, have a look at
`lib/basehandler.rb`.

* type `./run run` to test, `./run start` to daemonize

Demo handler: SQL storage of characters
---------------------------------------

There's a example handler in sequelhandler.rb. To use it, specify

    handler: sequel

in your config.yaml.

Also, you will need to set up database.yaml as shown in database.yaml.sample.

The demo handler depends on the sequel gem to be installed.

To set up the database, just run the provided migrations:

    sequel -m db/ database.yaml
