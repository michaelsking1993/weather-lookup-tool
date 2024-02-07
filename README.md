# README

## Weather Tool

This repository holds a test project that aims to present a weather tool through which a zip code is inputted,
and the current weather is outputted.

If this zip code's weather has been accessed within the last 30 minutes, the cached weather is shown along with
an indication of how much time is left before updated weather is fetched.

Many further things could be done with this project, such as an extended weather forecast.
However, for the sake of time, I decided not to go further.

To run the project, clone the repository, run `bundle`, then run `rails db:create`, then `rails db:migrate`,
fire up the server (`rails s`), and proceed to `localhost:3000` to play around with the project.

A few notes:

- While in development, I used a .ENV file to store the API key for the weather service - however, I have no way of passing the API key
to the tester, so I decided to leave it in the code.
- In production, I would have included more tests, particularly for the view itself, for the endpoint, and extra test
cases for the service. However, unfortunately my time is not unlimited, so I left those test cases out.