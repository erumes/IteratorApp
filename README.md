# README

This README documents whatever steps are necessary to get the application up and running.

* Install Ruby version - 3.0.0
* This app uses Rails version - 7.1.2

* Database initialization - After cloning the repo, run the folowing:
  `rails db:create db:migrate`

* Run `bundle install`

* Start rails server using `rails s`. The server will start on `localhost:3000`

* Sign Up with details mentioned in the form.

  * Two buttons will be available on screen, each for event A and event B. The functionality should allow Events to be created in Iterable, however without API-key, it won't work.

  * Logout button is also available on screen.
____________________________________________________________________________________________

* If you do not want to do app setup, and only test functionality, then you can run the test suite.
  * Run the test suite using `rspec spec`
