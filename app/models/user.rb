class User < ActiveRecord::Base
  has_and_belongs_to_many :roles

  validates :email, presence: true, length: { maximum: 255 }
  validates :username, presence: true, length: { maximum: 30 },
            uniqueness: { case_sensitive: false },
            format: { with: /\A(?=.*[a-z])[a-z\d]+\Z/i,
                      message: 'Only letters and numbers are allowed.' }

  def to_param
    username
  end

  def has_permission?(key)
    self.roles_having_permission(key).any?
  end

  alias_method :can?, :has_permission?

  def is_admin?
    (self.roles.where(key: 'admin').count > 0)
  end

  def roles_having_permission(key)
    self.roles.select{ |r| r.has_permission?(key) }
  end

end
