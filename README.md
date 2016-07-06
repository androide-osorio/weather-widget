Weather Widget
====

A Mini weather widget application developed in sintra and Angular 1.5.x that can fetch the current weather forecast in the user's current location (working with both IP location and HTML5 geolocation).

Features
---
* Fully Responsive
* Geolocation support built in, with fallback to IP based location
* Ability to change the widget's forecast location through the UI
* Fully developed API for fetching information about the current weather and week forecasts.
* Integration with Yahoo! Weather.

System Requirements
---
Make sure you have the following software installed on your server:

| Software    	| Version   	| Installation                               	|
|-------------	|-----------	|--------------------------------------------	|
| Ruby        	| >= 2.0.0  	| Specific for the OS. More information [here](https://www.ruby-lang.org/en/documentation/installation/) 	|
| Bundler gem 	| >= 1.12.x 	| `gem install bundle`                         	|
| rackup Gem  	| >= 1.3    	| `gem install rackup`                         	|

Frameworks and APIs used
---
* Sinatra framework for ruby.
* Yahoo Weather API for weather forecasts
* freegeoip.net for IP-Based location
* SPRockets for asset pipeline processing
* SASS for CSS preprocessing

Running the application
---
Clone this repository by Running:
```bash
$ git clone https://github.com/androide-osorio/weather-widget.git
```

Next, `cd` into the project's folder that you just cloned and run
```bash
$ bundle install
```

To run a local server where you can see the project up and running, use the command:
```bash
$ bundle exec rackup config.ru -p 5000
```
This will open a test server in `http://localhost:5000`.

Configuring the application
---
Currently, there is only one setting that can be configured: the default location the weather widget will load.

To configure it, open the `application.rb` file and look for the following line:
```ruby
# replace the value in quotes to change the location
set :location, 'Los Angeles, CA, United States'
```

Deploying to Production
---
To have this application running in a production server, you'll first need to have a web server installed. The following instructions are valid for the following setup:

* nginx as web server
* unicorn as the ruby application server
* Ubuntu 14.04+

### Installing production software
Install nginx in your server by running:
```bash
$ apt-get install nginx
```

Install the Unicorn gem by running:
```bash
$gem install Unicorn
```

Once you have installed this software, please open the `unicorn.rb` file and configure the correct routes and names the Unicorn server will use (in the provided file, replace `my-app` for the application's name):

```ruby
# Set the working application directory
# working_directory "/path/to/your/app"
working_directory "/var/www/my-app" # REPLACE THIS!
```

Next, configure the nginx web server by creating a new configuration file:
```bash
# Remove the default configuration file
rm -v /etc/nginx/sites-available/default

# Create a new, blank configuration
nano /etc/nginx/conf.d/default.conf
```
**note:** You may need to use `sudo` to perform this actions.

Configure the nxginx server accordingly (`/etc/nginx/conf.d/default.conf`), so it can communicate properly to the Unicorn gem. an example configuration is written below (make sure to replace the configurations accordingly):
```nginx
upstream app {
    # Path to Unicorn SOCK file, as defined previously
    server unix:<unicorn socket defined in unicorn.rb> fail_timeout=0;
}

server {
    listen 80;

    # Set the server name, similar to Apache's settings
    server_name localhost;

    # Application root, as defined previously
    root /path/to/project/public;

    try_files $uri/index.html $uri @app;

    location @app {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_redirect off;
        proxy_pass http://app;
    }

    error_page 500 502 503 504 /500.html;
    client_max_body_size 4G;
    keepalive_timeout 10;

}  
```

You can now start the unicorn process by running:
```bash
# Make sure that you are inside the application directory
unicorn -c unicorn.rb -D
```

And restart nginx to refresh the new configuration:
```bash
$ service nginx restart
```

There are a lot of other ways to deploying to production depending on your configuration. You can find more information in [this great article](https://www.digitalocean.com/community/tutorials/how-to-deploy-sinatra-based-ruby-web-applications-on-ubuntu-13)

Authors
---
Graphic and UX design by Hernando Botero
Development by Andrés Osorio
