# Karma

Application website: https://karmaradio.herokuapp.com


### Getting started
Installations:
- Install mix
- Install phoenix
- Install node (npm)
- Install redis
- Install postgres


To start the app you will need:
- Postgres running
- Redis server running (port 6379)
- pdftk: follow this link for mac: https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/pdftk_server-2.02-mac_osx-10.11-setup.pkg
  - if you're having issues take a look at this https://stackoverflow.com/questions/32505951/pdftk-server-on-os-x-10-11

Then run:
- Npm install
- Mix deps.get
- Mix ecto.create
- Mix ecto.migrate

Env variables:
- Add the .env file
- Run `source.env`

Start server:
- Mix phoenix.server


Now you can visit [`localhost:4000`](http://localhost:4000).
