# README

## Weather Tool

This repository holds a test project that aims to present a weather tool through which a zip code is inputted,
and the current weather is outputted.

If this zip code's weather has been accessed within the last 30 minutes, the cached weather is shown along with
an indication of how much time is left before updated weather is fetched.

If it has not been accessed within the last 30 minutes, the most up-to-date weather is shown.

If the zip code is invalid, an appropriate error message is shown.

Many further things could be done with this project, such as an extended weather forecast.
However, for the sake of time, I decided not to go further.

## SETUP
1. Clone the repository
2. Run `bundle install`
3. Run `rails db:create`
4. Run `rails db:migrate'
5. Create a `.env` file in the root directory, and copy/paste what is inside of `.env.sample` into it.
6. Fire up the server: `rails s`
7. Proceed to `localhost:3000` and play around with the app!

A few notes:

- While in development, I used a .ENV file to store the API key for the weather service - since I have no way of giving the project reviewer
the API key, I chose to paste this key directly into a .env.sample file. This should never be done in a production environment,
but as stated above, I have no other way of passing the API key to the tester.
- In production, I would have included more tests, particularly for the view itself, for the endpoint, and extra test
cases for the service. However, unfortunately my time is not unlimited, so I left those test cases out.