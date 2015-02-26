class Permission < ActiveRecord::Base
  has_and_belongs_to_many :roles

  validates :key, presence: true, length: { maximum: 255 },
            uniqueness: { case_sensitive: false }

  def name
    I18n.t "permission_#{key.gsub('.', '_')}"
  end

  def readonly?
    !new_record?
  end

end
