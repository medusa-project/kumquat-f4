class Item < Entity

  extend ActiveModel::Naming
  extend Forwardable
  delegate [:fedora_json_ld, :fedora_url, :triples, :uuid, :web_id] =>
               :fedora_container

  RESOURCE_TYPE = Fedora::ResourceType::ITEM

  @@http = HTTPClient.new

  attr_reader :children
  attr_accessor :collection
  attr_reader :fedora_container

  def initialize(params = {})
    @children = []
    params[:fedora_container] ||= Fedora::Container.new
    @fedora_container = params[:fedora_container]

    params.each do |k, v|
      if respond_to?("#{k}=")
        send "#{k}=", v
      else
        instance_variable_set "@#{k}", v
      end
    end
  end

  def ==(other)
    other.kind_of?(Item) and self.uuid == other.uuid
  end

  ##
  # @return array of Items
  #
  def children
    @children = Item.all.where(kq_parent_uuid: self.uuid).
        order(:kq_page_index) unless @children.any?
    @children
  end

  ##
  # @return Collection
  #
  def collection
    @collection = Collection.find_by_web_id(
        self.solr_representation['kq_collection_key']) unless @collection
    @collection
  end

  def delete(also_tombstone = false)
    self.fedora_container.delete(also_tombstone)
  end

  ##
  # @return Item
  #
  def parent
    unless @parent
      uuid = self.solr_representation['kq_parent_uuid']
      @parent = Item.find_by_uuid(uuid) if uuid
    end
    @parent
  end

  def persisted?
    !self.fedora_container.nil?
  end

  def to_model
    self
  end

  def to_param
    self.web_id
  end

  def save
    self.fedora_container.save
    # TODO: save associated dirty entities (bytestreams, collection)
  end

  # TODO: get rid of this
  def subtitle
    t = self.triples.select do |e|
      e.predicate.include?('http://purl.org/dc/terms/alternative')
    end
    t.first ? t.first.value : nil
  end

  ##
  # @see subtitle
  #
  def title
    t = self.triples.select do |e|
      e.predicate.include?('http://purl.org/dc/elements/1.1/title')
    end
    t.first ? t.first.value : 'Untitled'
  end

  def triple(predicate)
    t = self.triples.select do |e|
      e.predicate.include?(predicate)
    end
    t.first ? t.first.value : nil
  end

end
