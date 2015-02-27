# Getting Started

Kumquat has four main application dependencies:

1. PostgreSQL
2. Fedora
3. fcrepo-message-consumer
4. Solr

The instructions below should help you get these set up as quickly as possible.

## PostgreSQL

TODO: write this

## Fedora

[https://wiki.duraspace.org/display/FEDORA41/Deploying+Fedora+4+Complete+Guide]
(https://wiki.duraspace.org/display/FEDORA41/Deploying+Fedora+4+Complete+Guide)

## fcrepo-message-consumer

### Install

`git clone git@github.com:fcrepo4/fcrepo-message-consumer.git`

Edit `fcrepo-message-consumer/fcrepo-message-consumer-webapp/src/main/resources/spring/indexer-core.xml`:

    <!-- Solr Indexer START-->
    <bean id="solrIndexer" class="org.fcrepo.indexer.solr.SolrIndexer">
      <constructor-arg ref="solrServer" />
    </bean>
    <!--External Solr Server  -->
    <bean id="solrServer" class="org.apache.solr.client.solrj.impl.HttpSolrServer">
      <constructor-arg index="0" value="http://${fcrepo.host:localhost}:${solrIndexer.port:8983}/solr/" />
    </bean>
    <!-- Solr Indexer END-->

    <!-- Message Driven POJO (MDP) that manages individual indexers -->
     <bean id="indexerGroup" class="org.fcrepo.indexer.IndexerGroup">
      <constructor-arg name="indexers">
        <set>
        <!--
          <ref bean="jcrXmlPersist"/>
          <ref bean="fileSerializer"/>
          <ref bean="sparqlUpdate"/> -->
          <!--To enable solr Indexer, please uncomment line below  -->
          <ref bean="solrIndexer"/>
        </set>
      </constructor-arg>

      <!-- If your Fedora instance requires authentication, enter the
           credentials here. Leave blank if your repo is open. -->
      <constructor-arg name="fedoraUsername" value="${fcrepo.username:}" /> <!-- i.e., manager, tomcat, etc. -->
      <constructor-arg name="fedoraPassword" value="${fcrepo.password:}" />
    </bean>

### Start

`mvn clean install -DskipTests`

`cd fcrepo-message-consumer-webapp`

`mvn -Djetty.port=9999 jetty:run`

## Solr

### Install

`wget http://mirror.cogentco.com/pub/apache/lucene/solr/4.10.3/solr-4.10.3.tgz`

`tar -xzf solr-4.10.3.tgz`

### Configure

Edit `solr-4.10.3/example/solr/collection1/conf/solrconfig.xml`:

Uncomment the following XML block:

    <schemaFactory class="ManagedIndexSchemaFactory">
      <bool name="mutable">true</bool>
      <str name="managedSchemaResourceName">managed-schema</str>
    </schemaFactory>

Comment out the following XML block:

    <!-- <schemaFactory class="ClassicIndexSchemaFactory"/> -->

### Start

`cd solr-4.6.0/example`

`java -jar start.jar`

Verify that Solr is running at [http://localhost:8983/solr]
(http://localhost:8983/solr).

## Kumquat

### Install RVM

`gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3`

`\curl -sSL https://get.rvm.io | bash -s stable`

### Install Bundler

`gem install bundler`

### Check out the code

`git clone https://YOUR_NETID@code.library.illinois.edu/scm/kq/kumquat.git`

`cd kumquat`

*(Note: the default branch is `develop`, in accordance with the
[Gitflow](https://www.atlassian.com/git/tutorials/comparing-workflows/feature-branch-workflow)
branching model.)*

### Install dependent gems

`bundle install`

### Configure the app

`cd config`

`cp database.default.yml database.yml`

`cp kumquat.default.yml kumquat.yml`

Edit these as necessary.

### Create the database

`bundle exec rake db:setup`

### Start the app

`rails server`

Go to [http://localhost:3000/](http://localhost:3000/).
