# [engineering.nike.com/cerberus](engineering.nike.com/cerberus)

## Cerberus

The source code for [engineering.nike.com/cerberus](engineering.nike.com/cerberus)

Used to document Cerberus and its related components.

### Development
This GitHub page is a [Jekyll](https://jekyllrb.com/) site.

To run the site locally you will need to get [Jekyll](https://jekyllrb.com/docs/installation/) up and running.

You should be able to do that via running `bundle install`, you will need [Ruby](https://www.ruby-lang.org/en/documentation/installation/) and [Bundler](http://bundler.io/) installed for that.

If your using Mac OS X and have issues with nokogiri checkout this [Stack Overflow](https://stackoverflow.com/questions/37711814/error-installing-rails-on-os-x-el-capitan/39929160#39929160) answer that I found useful.

Once you have Jekyll installed you can host the site by running the following command `bundle exec jekyll serve -w --config _config.yml,_dev_config.yml`

Enable live reloading by using `bundle exec guard`

### License

See the [LICENSE](https://github.com/Nike-Inc/cerberus/blob/master/LICENSE.md) file.
