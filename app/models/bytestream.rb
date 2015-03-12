##
# Encapsulates a Fedora binary resource. Bytestreams implement a similar API
# as ActiveKumquat::Base, but do not descend from that class as they are not
# indexable, so they cannot be retrieved with finder methods.
#
class Bytestream

  include ActiveModel::Model

  ENTITY_TYPE = ActiveKumquat::Base::Type::BYTESTREAM

  attr_accessor :external_resource_url # string
  attr_accessor :height # integer
  attr_accessor :media_type # string
  attr_accessor :owner # ActiveKumquat::Base subclass
  attr_accessor :repository_url # string
  attr_accessor :type # Bytestream::Type
  attr_accessor :upload_pathname # string
  attr_accessor :uuid # string
  attr_accessor :width # integer

  validates_presence_of :media_type
  validates_presence_of :owner

  class Type
    DERIVATIVE = 'derivative'
    MASTER = 'master'
  end

  @@http = HTTPClient.new
  @@solr = RSolr.connect(url: Kumquat::Application.kumquat_config[:solr_url])

  def initialize(params = {})
    params.except(:id, :uuid).each do |k, v|
      send("#{k}=", v) if respond_to?("#{k}=")
    end
    @destroyed = false
    @persisted = false
    self.read_media_type unless self.media_type
    self.read_dimensions unless self.width and self.height
  end

  ##
  # @param also_tombstone boolean
  # @param commit_immediately boolean
  #
  def delete(also_tombstone = false, commit_immediately = true)
    if self.repository_url
      url = self.repository_url.chomp('/')
      @@http.delete(url)
      @@http.delete("#{url}/fcr:tombstone") if also_tombstone
      @destroyed = true
      @persisted = false
      self.owner.bytestreams.delete(self)

      if commit_immediately
        # wait for solr to get the delete from fcrepo-message-consumer
        # TODO: this is horrible
        sleep 2
        @@solr.commit
      end
    end
  end

  alias_method :destroy, :delete
  alias_method :destroy!, :delete

  def destroyed?
    @destroyed
  end

  def persisted?
    @persisted and !@destroyed
  end

  ##
  # Populates the instance with data from an RDF graph.
  #
  # @param graph RDF::Graph
  #
  def populate_from_graph(graph)
    graph.each_triple do |subject, predicate, object|
      if predicate == "#{Kumquat::Application::NAMESPACE_URI}mediaType"
        self.media_type = object.to_s
      elsif predicate == "#{Kumquat::Application::NAMESPACE_URI}height"
        self.height = object.to_s.to_i
      elsif predicate == "#{Kumquat::Application::NAMESPACE_URI}bytestreamType"
        self.type = object.to_s
      elsif predicate == "#{Kumquat::Application::NAMESPACE_URI}width"
        self.width = object.to_s.to_i
      elsif predicate == 'http://fedora.info/definitions/v4/repository#uuid'
        self.uuid = object.to_s
      end
    end
    @fedora_graph = graph
    @persisted = true
  end

  ##
  # Reads the width and height (if an image) and assigns them to the instance.
  # Only works for images.
  #
  def read_dimensions
    if self.media_type and self.media_type.start_with?('image/')
      begin
        if self.upload_pathname
          img = Magick::Image.read(self.upload_pathname).first
          self.width = img.columns
          self.height = img.rows
        elsif self.external_resource_url
          response = @@http.get(self.external_resource_url)
          img = Magick::Image.read(response.body).first
          self.width = img.columns
          self.height = img.rows
        end
      rescue Magick::ImageMagickError => e
        # nothing we can do
        Rails.logger.debug(e.message)
      end
    end
  end

  def read_media_type
    type = nil
    if self.upload_pathname and File.exist?(self.upload_pathname)
      type = MimeMagic.by_path(self.upload_pathname).to_s ||
          MimeMagic.by_magic(File.open(self.upload_pathname)).to_s
    elsif self.external_resource_url
      type = MimeMagic.by_extension(self.external_resource_url).to_s
    end
    self.media_type = type if type
  end

  def reload!
    response = @@http.get(self.repository_metadata_url, nil,
                          { 'Accept' => 'application/n-triples' })
    graph = RDF::Graph.new
    graph.from_ntriples(response.body)
    self.populate_from_graph(graph)
  end

  def repository_metadata_url
    "#{self.repository_url.chomp('/')}/fcr:metadata"
  end

  def save(commit_immediately = true) # TODO: look into Solr soft commits
    raise "Validation error: #{self.errors.messages.first}" unless self.valid?
    if self.destroyed?
      raise RuntimeError, 'Cannot save a destroyed object.'
    elsif self.uuid
      save_existing
    else
      save_new
    end
    @persisted = true
    self.owner.bytestreams << self
    if commit_immediately
      # wait for solr to get the add from fcrepo-message-consumer
      # TODO: this is horrible (also doing it in delete())
      sleep 2
      @@solr.commit
    end
  end

  alias_method :save!, :save

  def to_param
    self.uuid
  end

  def to_sparql_update
    update = ActiveKumquat::SparqlUpdate.new
    update.prefix('kumquat', Kumquat::Application::NAMESPACE_URI)
    owner_uri = "<#{self.owner.repository_url}>"
    my_uri = "<#{self.repository_url}>"
    my_metadata_uri = "<#{self.repository_metadata_url}>"
    update.delete(my_metadata_uri, '<kumquat:mediaType>', '?o').
        insert(my_metadata_uri, 'kumquat:mediaType', self.media_type)
    update.delete(my_metadata_uri, '<kumquat:bytestreamType>', '?o').
        insert(my_metadata_uri, 'kumquat:bytestreamType', self.type)
    update.delete(my_metadata_uri, '<kumquat:width>', '?o').
        insert(my_metadata_uri, 'kumquat:width', self.width)
    update.delete(my_metadata_uri, '<kumquat:height>', '?o').
        insert(my_metadata_uri, 'kumquat:height', self.height)
    update.delete(my_metadata_uri, '<kumquat:resourceType>', '?o').
        insert(my_metadata_uri, 'kumquat:resourceType', ENTITY_TYPE)
    update.delete(owner_uri, '<kumquat:hasMasterBytestream>', '?o').
        insert(owner_uri, 'kumquat:hasMasterBytestream', my_uri, false)
  end

  private

  ##
  # Updates an existing bytestream.
  #
  def save_existing
    update = self.to_sparql_update
    @@http.patch(self.repository_metadata_url, update.to_s,
                 { 'Content-Type' => 'application/sparql-update' })
  end

  ##
  # Creates a new bytestream.
  #
  def save_new
    raise 'Validation error' unless self.valid?
    raise 'Owner must have a Fedora container URL before a bytestream can be '\
      'added.' unless self.owner.repository_url
    response = nil
    if self.upload_pathname
      File.open(self.upload_pathname) do |file|
        filename = File.basename(self.upload_pathname)
        headers = {
            'Content-Type' => self.media_type,
            'Content-Disposition' => "attachment; filename=\"#{filename}\"",
            'Slug' => "#{self.type}-bytestream"
        }
        response = @@http.post(self.owner.repository_url, file, headers)
      end
    elsif self.external_resource_url
      response = @@http.post(self.owner.repository_url, nil,
                             { 'Content-Type' => 'text/plain' })
      headers = { 'Content-Type' => "message/external-body; "\
        "access-type=URL; URL=\"#{self.external_resource_url}\"" }
      @@http.put(response.header['Location'].first, nil, headers)
    end
    self.repository_url = response.header['Location'].first
    save_existing
  end

end
