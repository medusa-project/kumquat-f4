class Triple < ActiveRecord::Base

  belongs_to :metadata_profile, inverse_of: :triples

  after_save :adjust_profile_triple_indexes_after_save
  after_destroy :adjust_profile_triple_indexes_after_destroy

  private

  ##
  # Updates the indexes of all triples in the same metadata profile to ensure
  # that they are non-repeating and properly gapped.
  #
  def adjust_profile_triple_indexes_after_destroy
    if self.metadata_profile and self.destroyed?
      self.metadata_profile.triples.order(:index).each_with_index do |triple, i|
        triple.update_column(:index, i) # update_column skips callbacks
      end
    end
  end

  ##
  # Updates the indexes of all triples in the same metadata profile to ensure
  # that they are non-repeating and properly gapped.
  #
  def adjust_profile_triple_indexes_after_save
    if self.metadata_profile and self.changed.include?('index')
      self.metadata_profile.triples.where('id != ?', self.id).order(:index).
          each_with_index do |triple, i|
        # update_column skips callbacks
        triple.update_column(:index, (i >= self.index) ? i + 1 : i)
      end
    end
  end

end
