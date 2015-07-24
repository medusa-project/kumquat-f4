class ReindexCommand < Command

  def self.required_permissions
    super + [Permission::REINDEX]
  end

  def execute
    Repository::Fedora.new.reindex
  end

end
