# Getting Started (OS X/Homebrew)

Kumquat has several dependencies that need to be installed first:

* ImageMagick
* PostgreSQL
* Fedora
* fcrepo-message-consumer
* Solr
* Loris

These will be covered in sequence.

## Installing

### ImageMagick

`$ brew install imagemagick --with-jp2 --with-gs`

The `--with-*` flags are important; if you already have ImageMagick installed,
make sure you also have the JPEG2000 and PDF delegates by searching for them in
the output of `$ identify -list format`.

### PostgreSQL

TODO: write this

### Fedora

[https://wiki.duraspace.org/display/FEDORA41/Deploying+Fedora+4+Complete+Guide]
(https://wiki.duraspace.org/display/FEDORA41/Deploying+Fedora+4+Complete+Guide)

### fcrepo-message-consumer

1. `$ git clone git@github.com:fcrepo4/fcrepo-message-consumer.git`

2. Open `fcrepo-message-consumer/fcrepo-message-consumer-webapp/src/main/resources/spring/indexer-core.xml`
   and uncomment the `<ref bean="solrIndexer"/>` tag.

### Solr

1. `$ curl -O http://mirror.cogentco.com/pub/apache/lucene/solr/4.10.3/solr-4.10.3.tgz`

2. `$ tar xfz solr-4.10.3.tgz`

### Loris

The following instructions will set up Loris using the version of Apache
included with OS X. There is also an alternative option using Docker which is
not covered here; see the
[https://github.com/pulibrary/loris/blob/development/docker/README.md](Loris
website).

#### Create a user and group

`$ sudo dscl . create /Users/loris`

`$ sudo dscl . create /Users/loris UserShell /bin/bash`

`$ sudo dscl . create /Users/loris RealName "Loris User"`

`$ sudo dscl . create /Users/loris UniqueID 300`

`$ sudo dscl . create /Users/loris PrimaryGroupID 300`

`$ sudo dscl . create /Groups/loris gid 300`

`$ sudo dscl . create /Groups/loris passwd "*"`

`$ sudo dscl . create /Groups/loris GroupMembership loris`

#### Install mod_wsgi

`$ git clone https://github.com/GrahamDumpleton/mod_wsgi.git`

`$ cd mod_wsgi`

`$ ./configure`

`$ make`

`$ sudo make install`

#### Install Python dependencies

`$ sudo pip install configobj Pillow werkzeug logging requests`

#### Install Loris

`$ git clone https://github.com/pulibrary/loris.git`

`$ cd loris`

`$ sudo ./setup.py install`

`$ sudo mkdir /var/log/loris /var/cache/loris`

`$ sudo touch /var/log/loris/loris.log`

`$ sudo chown -R loris:loris /var/log/loris /var/cache/loris`

`$ sudo cp etc/loris2.conf /etc/loris2`

#### Configure Apache

1. Add the following line to `/etc/apache2/httpd.conf`:

   `LoadModule wsgi_module libexec/apache2/mod_wsgi.so`

   and make sure the `headers_module` and `expires_module` lines are
   uncommented.

2. `$ cd /etc/apache2/other`

   Create a file here called `loris.conf` containing:

        ExpiresActive On
        ExpiresDefault "access plus 5184000 seconds"

        AllowEncodedSlashes On

        WSGIDaemonProcess loris user=loris group=loris processes=10 threads=15 maximum-requests=10000
        WSGIScriptAlias /loris /var/www/loris2/loris2.wsgi
        WSGIProcessGroup loris

        SetEnvIf Request_URI ^/loris loris
        CustomLog ${APACHE_LOG_DIR}/loris-access.log combined env=loris

3. Verify that the configuration is valid: `$ apachectl configtest`

### Kumquat

#### Install RVM

`$ gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3`

`$ \curl -sSL https://get.rvm.io | bash -s stable`

#### Install Bundler

`$ gem install bundler`

#### Check out the code

`$ git clone https://YOUR_NETID@code.library.illinois.edu/scm/kq/kumquat.git`

`$ cd kumquat`

*(Note: the default branch is `develop`, in accordance with the
[Gitflow](https://www.atlassian.com/git/tutorials/comparing-workflows/feature-branch-workflow)
branching model.)*

#### Install dependent gems

`$ bundle install`

#### Configure the app

`$ cd config`

`$ cp database.default.yml database.yml`

`$ cp kumquat.default.yml kumquat.yml`

Edit these as necessary.

Also copy `kumquat/config/schema.xml` to `solr-4.10.3/example/solr/collection1/conf/schema.xml`.

#### Create the database

`$ bundle exec rake db:setup`

## Running

### Fedora

`$ cd fcrepo-4.x.x/f4-base`

`$ java -jar ../start.jar`

### fcrepo-message-consumer

`$ mvn clean install -DskipTests`

`$ cd fcrepo-message-consumer-webapp`

`$ mvn -Djetty.port=9999 jetty:run`

### Solr

`$ cd solr-4.10.3/example`

`$ java -jar start.jar`

Verify that Solr is running at [http://localhost:8983/solr]
(http://localhost:8983/solr).

### Loris

`$ apachectl stop`

`$ apachectl start`

### Kumquat

1. Install/update Kumquat's Fedora indexing transform:

  `$ bundle exec rake kumquat:update_indexing`

2. `$ rails server`

Go to [http://localhost:3000/](http://localhost:3000/) in a web browser.
