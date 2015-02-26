class User < ActiveRecord::Base
  has_and_belongs_to_many :roles

  validates :username, presence: true, length: { maximum: 255 },
            uniqueness: { case_sensitive: false },
            format: { with: /\A(?=.*[a-z])[a-z\d]+\Z/i,
                      message: 'Only letters and numbers are allowed.' }

  def to_param
    username
  end

  def has_permission?(key)
    self.roles.each do |role|
      return true if role.has_permission?(key)
    end
    false
  end

  def is_admin?
    self.roles.each do |role|
      return true if role.key == 'admin'
    end
    false
  end

  def roles_having_permission(key)
    self.roles.select{ |r| r.has_permission?(key) }
  end

end
