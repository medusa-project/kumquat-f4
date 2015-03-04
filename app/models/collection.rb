class Collection < Entity

  RESOURCE_TYPE = Fedora::ResourceType::COLLECTION

  include ActiveModel::Model
  include Introspection

  @@http = HTTPClient.new

  delegate :fedora_json_ld, :fedora_url, :triples, :uuid, :web_id,
           to: :fedora_container

  attr_reader :fedora_container
  attr_reader :items
  attr_accessor :key

  validates :key, length: { minimum: 2, maximum: 20 }

  def initialize(params = {})
    @items = []
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

  def delete(also_tombstone = false)
    self.fedora_container.delete(also_tombstone)
  end

  def items
    unless @items.any?
      self.fedora_container.items.each do |c|
        item = Item.new(fedora_container: c)
        item.collection = self
        @items << item
      end
    end
    @items
  end

  def num_items
    @num_items = Item.where(kq_collection_key: self.web_id).
        where('-kq_parent_uuid:[* TO *]').count unless @num_items
    @num_items
  end

  def to_param
    self.web_id
  end

  def save
    self.fedora_container.save
  end

  alias_method :save!, :save

  def subtitle
    t = self.triples.select do |e|
      e.predicate.include?('http://purl.org/dc/terms/alternative')
    end
    t.first ? t.first.value : nil
  end

  def title
    t = self.triples.select do |e|
      e.predicate.include?('http://purl.org/dc/elements/1.1/title')
    end
    t.first ? t.first.value : nil
  end

  def title=(title)
    self.triples.reject!{ |t| t.predicate.include?('/title') }
    self.triples << Triple.new(predicate: 'http://purl.org/dc/elements/1.1/title',
                               object: title) unless title.blank?
  end

  def triple(predicate)
    t = self.triples.select do |e|
      e.predicate.include?(predicate)
    end
    t.first ? t.first.value : nil
  end

end
