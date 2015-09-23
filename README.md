# Getting Started (OS X/Homebrew)

Kumquat has several dependencies that need to be installed first:

* ImageMagick
* ffmpeg
* PostgreSQL
* Fedora (see ActiveMedusa readme for details)
* Solr 5.2+
* IIIF Image API 2.0-compliant image server

These will be covered in sequence.

## Installing

### ImageMagick

`$ brew install imagemagick --with-jp2 --with-gs`

The `--with-*` flags are important; if you already have ImageMagick installed,
make sure you also have the JPEG2000 and PDF delegates by searching for them in
the output of `$ identify -list format`.

### ffmpeg

`$ brew install ffmpeg --with-fdk-aac --with-libvpx --with-libvorbis`

### PostgreSQL

`$ brew install postgresql`

### Fedora

[https://wiki.duraspace.org/display/FEDORA4x/Deploying+Fedora+4+Complete+Guide]
(https://wiki.duraspace.org/display/FEDORA4x/Deploying+Fedora+4+Complete+Guide])

### Solr

Download and extract Solr. Create a core for Kumquat by copying
`config/solr/kumquat` into `solr-5.x.x/server/solr`.

### IIIF Image API 2.0 image server

The easiest server to get running is [Cantaloupe]
(https://github.com/medusa-project/cantaloupe). Use the `HttpResolver` and set
`HttpResolver.uri_prefix` to the Fedora root container.

### Kumquat

#### Install RVM

`$ gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3`

`$ \curl -sSL https://get.rvm.io | bash -s stable`

#### Check out the code

`$ git clone https://github.com/medusa-project/kumquat`

`$ cd kumquat`

*(Note: the default branch is `develop`, in accordance with the
[Gitflow](https://www.atlassian.com/git/tutorials/comparing-workflows/feature-branch-workflow)
branching model.)*

#### Install Bundler

`$ gem install bundler`

#### Install dependent gems

`$ bundle install`

#### Configure the app

`$ cd config`

`$ cp database.default.yml database.yml`

`$ cp kumquat.default.yml kumquat.yml`

Edit these as necessary.

#### Create and seed the database

`$ bundle exec rake db:setup`

## Running

### Fedora

`$ cd fcrepo-4.x.x/f4-base`

`$ java -jar ../start.jar`

### Solr

`$ solr-5.x.x/bin/solr start`

### Cantaloupe

`$ java -Dcantaloupe.config=/path/to/cantaloupe.properties -jar Cantaloupe-x.x.x.jar`

### Delayed Job

Delayed Job is used to execute background jobs, which are typically invoked in
the Control Panel.

`$ bundle exec rake jobs:work`

### Kumquat

1. Install/update the Solr schema:

  `$ bundle exec rake solr:update_schema`

2. Import the demo collections:

  `$ bundle exec rake kumquat:import_demo`

3. `$ rails server`

Go to [http://localhost:3000/](http://localhost:3000/) in a web browser.
