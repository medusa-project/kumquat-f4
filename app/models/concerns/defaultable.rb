##
# Ensures that the instance, if marked as default, is the only one of its type
# that is the default. Can be mixed into model classes that have a Boolean
# `default` property.
#
module Defaultable

  extend ActiveSupport::Concern

  included do
    after_save :ensure_default_uniqueness
  end

  ##
  # Makes all other instance "not default" if the instance is the default.
  #
  def ensure_default_uniqueness
    if self.default
      self.class.all.where('id != ?', self.id).each do |instance|
        instance.default = false
        instance.save!
      end
    end
  end

end
