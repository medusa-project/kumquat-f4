##
# Reopens `ActiveMedusa::Facet` and `ActiveMedusa::Facet::Term` to add some
# useful methods.
#
module ActiveMedusa

  class Facet

    class Term

      ##
      # @param params Rails params hash
      # @return input hash
      #
      def added_to_params(params)
        params[:fq] = [] unless params[:fq].respond_to?(:each)
        params[:fq] = params[:fq].reject do |t|
          t.start_with?("#{self.facet.field.chomp('_facet')}:")
        end
        params[:fq] << self.facet_query
        params
      end

      def facet_query
        "#{self.facet.field}:\"#{self.name}\""
      end

      ##
      # @param params Rails params hash
      # @return input hash
      #
      def removed_from_params(params)
        params[:fq] = [] unless params[:fq].respond_to?(:each)
        params[:fq] = params[:fq].reject { |t| t == self.facet_query }
        params
      end

    end # Term

    def label
      I18n.t("solr_field_#{self.field}")
    end

  end

end
