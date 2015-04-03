class User < ActiveRecord::Base
  has_and_belongs_to_many :roles

  validates :email, presence: true, length: { maximum: 255 }
  validates :password, length: { minimum: 5 }, if: :should_validate_password?
  validates :username, presence: true, length: { maximum: 30 },
            uniqueness: { case_sensitive: false },
            format: { with: /\A(?=.*[a-z])[a-z\d]+\Z/i,
                      message: 'Only letters and numbers are allowed.' }

  validate :validate_password_confirmation, if: :should_validate_password?

  has_secure_password

  def to_param
    username
  end

  def has_permission?(key)
    self.roles_having_permission(key).any?
  end

  alias_method :can?, :has_permission?

  def is_admin?
    self.roles.where(key: 'admin').any?
  end

  def roles_having_permission(key)
    self.roles.select{ |r| r.has_permission?(key) }
  end

  private

  def should_validate_password?
    password.present? or password_confirmation.present?
  end

  def validate_password_confirmation
    if self.password != self.password_confirmation
      errors[:base] << 'Passwords do not match.'
    end
  end

end
