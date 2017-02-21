
# For information about Cerberus, please see [http://engineering.nike.com/cerberus](http://engineering.nike.com/cerberus)

# Cerberus

Cerberus is a system for safely storing and managing secrets, targeted to running cloud 
applications in AWS.

This project is the source code for the [Cerberus website](http://engineering.nike.com/cerberus).

Please see the [Cerberus website](http://engineering.nike.com/cerberus) for more information
about Cerberus and to get an overview of the 
various [components](http://engineering.nike.com/cerberus/components/).

## Cerberus Website Development

This GitHub page is a [Jekyll](https://jekyllrb.com/) site.

To run the site locally you will need to get [Jekyll](https://jekyllrb.com/docs/installation/) up and running. For
example, you can do this using [Ruby](https://www.ruby-lang.org/en/documentation/installation/) and
[Bundler](http://bundler.io/):

```
sudo gem install bundler
sudo bundle install
bundle exec jekyll serve -w --config _config.yml,_dev_config.yml 
```

If your using Mac OS X and have issues with nokogiri checkout this [Stack Overflow](https://stackoverflow.com/questions/37711814/error-installing-rails-on-os-x-el-capitan/39929160#39929160) answer that I found useful.

Enable live reloading by using `bundle exec guard`

## License

See the [LICENSE](https://github.com/Nike-Inc/cerberus/blob/master/LICENSE.md) file.
