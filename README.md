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
