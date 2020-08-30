# Wario

Mirrors Monzo transactions to an Airtable base.

Want a better handle on your money? Leave it to Wario!

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

## Setup

You can run this either with a local Rails install or Docker. Docker tends to be the easier option.

Set the following environment variables. You can retrieve these from [Airtable's API docs for your base](https://airtable.com/api).

- AIRTABLE_BASE - the ID of your target base, from [Airtable's API docs for your base](https://airtable.com/api)
- AIRTABLE_API_KEY - your personal API key, from [your account page on Airtable](https://airtable.com/account)

Now, choose how you'd prefer to run it:

### Docker

`docker-compose up` builds the host container and runs it. From there, you can use `docker-compose exec web bundle exec rails db:create db:setup` to create and configure the database.

### Rails (host machine)

Ensure you have the Bundler gem and PostgreSQL installed locally, then run `bundle install`. You'll also want to set up the database with `bundle exec rails db:create db:setup`.

## History

This is something I've tried to do in the past, and I've admittedly made some questionable technical decisions in previous attempts. My first attempt was similar to this one, but it spat out an Excel spreadsheet instead. At the time, I wasn't sure how I could 100% ensure that every transaction would be recorded, and also had to rely on running it as a script locally whenever I wanted to figure out my finances.

My second attempt wrote metadata to the Monzo transactions themselves, and was a React app with a Rails API middleman that I used to access and manipulate that data. This proved to be very slow for reasons I'm still unsure of - was the Monzo API slow, or were the ways I was transforming the data inefficient? Regardless, I'm not too proud of this attempt, even if it gave me a good opportunity to sharpen and exercise a lot of React knowledge.

This is my current attempt, and I think it's much better than these because:

- Airtable takes care of the frontend in a way that's both familiar and friendly, at least once you've got everything else configured
- You can control the metrics and calculations you want to use through Airtable yourself and tailor it to your own needs

## Caveats and their fixes:

- Airtable allows duplicate records, but Wario mitigates this by checking if a record already exists    
- The request to Airtable might fail, but Wario caches records <!-- TODO: and deletes them if the update/create was successful -->

## To come

- A backlog task you can run on the daily (#8)
- Automatic classification of Piggybank contributions and other pot actions (#9)
- A multitenanted option for folks who'd rather not roll their own (#10)
- Documentation and improvement on Airtable configuration (#11, #12, #13)