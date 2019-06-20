[![build status](https://gitlab.com/fiuba-memo2/tp2/invernalia-bot/badges/master/build.svg)](https://gitlab.com/fiuba-memo2/tp2/invernalia-bot/commits/master)

GuaraBOT

This telegram bot was designed to be a client of the following API: https://gitlab.com/fiuba-memo2/tp2/invernalia-api (Guara API)

## Application setup

1. Run **_bundle install --without staging production_**, to install all application dependencies
1. Run **_bundle exec rake_**, to run all tests and ensure everything is properly setup

## Some conventions to work on it:

* Follow existing coding conventions
* Use feature branch
* Add descriptive commits messages to every commit
* Write code and comments in English

## Enviroment variables setup:

TELEGRAM_TOKEN=710048435:AAGNWXx19z8CHY6_MgcMjgcizWWnHvI5vyw
URL_API=http://localhost:3000/
HTTP_API_TOKEN=CPLpXxWL8TvM7IXmBRVlRWFiHIbk0jDu

* Talk to BotFather (https://web.telegram.org/#/im?p=@BotFather) with the command /newbot to set the variable TELEGRAM_TOKEN 
* URL_API: The URL where your Guara API is running
* Set HTTP_API_TOKEN (if it was set up in Guara API) to be able to send the requests

## How to deploy to heroku:
* Sign up in heroku: https://signup.heroku.com/
* Create a new application
* Go to settings -> reveal config vars, and add the same variables described in the previous step
* Go to .gitlab-cy.yml, and if for example, you are deploying to a staging enviroment, configure the deploy_staging stage with your heroku app name and api-key (api-key should be set in gitlab enviroment variables but at the moment this gitlab's feature is bugged)
* Make sure you have a Procfile with the line bot: ruby app.rb
* Merge the current branch to staging branch and it will deploy automatically to heroku 
* Repeat as many times as environments need (You will also need to create new telegram bots)

## How to use the Bot:

* The bot is intended to be used only by students, current commands:
* Please make sure to have set your first and last name in Telegram, also you must set up an alias name in the configuration

/start starts the bot
/help shows the list of current commands
/oferta shows the academic offer
/inscripcion shows subjects for suscription
/estado shows subjects so you can consult your status in the selected subject
/nota shows subjects so students can consult their qualification in the selected subject
/misInscripciones shows your subject suscriptions
/promedio shows the quantity of approved subjects and your historical average

Contributors:

- Santiago Bianco
- Santiago Weber
- Tomás Pinto
