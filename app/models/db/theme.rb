module DB

  class Theme < ActiveRecord::Base

    has_many :collections, class_name: 'DB::Collection'

    validates :name, length: { minimum: 2, maximum: 30 },
              uniqueness: { case_sensitive: false }

    before_save :ensure_default_uniqueness

    self.table_name = 'themes'

    ##
    # @return DB::Theme
    #
    def self.default
      Theme.where(default: true).limit(1).first
    end

    ##
    # Returns the expected pathname of the theme's folder relative to the
    # application root.
    #
    # @return string
    #
    def pathname
      if self.required
        return File.join('app', 'views')
      end
      File.join('local', 'themes', self.name.downcase.gsub(' ', '_'))
    end

    private

    ##
    # Makes all other themes "not default" if the instance is the default.
    #
    def ensure_default_uniqueness
      if self.default
        if self.id
          Theme.all.where('id != ?', self.id).each do |theme|
            theme.default = false
            theme.save!
          end
        else
          Theme.all.each { |theme| theme.default = false; theme.save! }
        end
      end
    end

  end

end
