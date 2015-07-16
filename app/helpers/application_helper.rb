module ApplicationHelper

  def bootstrap_class_for(flash_type)
    case flash_type.to_sym
      when :success
        'alert-success'
      when :error
        'alert-danger'
      when :alert
        'alert-block'
      when :notice
        'alert-info'
      else
        flash_type.to_s
    end
  end

  ##
  # @param options [Hash]
  # @option options [Repository::Collection] :collection
  # @option options [ItemsController::BrowseContext] :context
  # @option options [String] :context_url
  # @option options [Repository::Item] :item
  # @return [String]
  #
  def breadcrumb(options = {})
    case controller_name
      when 'collections'
        case action_name
          when 'index'
            return collections_view_breadcrumb
          when 'show'
            return collection_view_breadcrumb(options[:collection])
        end
      when 'items'
        case action_name
          when 'index'
            return results_breadcrumb(options[:collection], options[:context])
          when 'show'
            return item_view_breadcrumb(options[:item], options[:context],
                                        options[:context_url])
        end
    end
    nil
  end

  private

  def collection_view_breadcrumb(collection)
    html = "<ol class=\"breadcrumb\">"\
      "<li>#{link_to 'Home', root_path}</li>"\
      "<li>#{link_to 'Collections', repository_collections_path}</li>"\
      "<li class=\"active\">#{truncate(collection.title, length: 50)}</li>"\
    "</ol>"
    raw(html)
  end

  def collections_view_breadcrumb
    nil # no breadcrumb in this view
  end

  def item_view_breadcrumb(item, context, context_url)
    case context
      when ItemsController::BrowseContext::SEARCHING
        html = "<ol class=\"breadcrumb\">"\
          "<li>#{link_to 'Home', root_path}</li>"\
          "<li>#{link_to 'Search', context_url}</li>"
        if item.parent_item
          html += "<li>#{link_to item.parent_item.title, item.parent_item}</li>"
        end
        html += "<li class=\"active\">#{truncate(item.title, length: 50)}</li>"\
          "</ol>"
      when ItemsController::BrowseContext::BROWSING_COLLECTION
        html += "<ol class=\"breadcrumb\">"\
          "<li>#{link_to 'Home', root_path}</li>"\
          "<li>#{link_to 'Collections', repository_collections_path}</li>"\
          "<li>#{link_to item.collection.title, item.collection}</li>"\
          "<li>#{link_to 'Items', repository_collection_items_path(item.collection)}</li>"
        if item.parent_item
          html += "<li>#{link_to item.parent_item.title, item.parent_item}</li>"
        end
        html += "<li class=\"active\">#{truncate(item.title, length: 50)}</li>"\
          "</ol>"
      when ItemsController::BrowseContext::BROWSING_ALL_ITEMS
        html = "<ol class=\"breadcrumb\">"\
          "<li>#{link_to 'Home', root_path}</li>"\
          "<li>#{link_to 'All Items', repository_items_path}</li>"
        if item.parent_item
          html += "<li>#{link_to item.parent_item.title, item.parent_item}</li>"
        end
        html += "<li class=\"active\">#{truncate(item.title, length: 50)}</li>"\
          "</ol>"
      when ItemsController::BrowseContext::FAVORITES
        html = "<ol class=\"breadcrumb\">"\
          "<li>#{link_to 'Home', root_path}</li>"\
          "<li>#{link_to 'Favorites', favorites_path}</li>"
        if item.parent_item
          html += "<li>#{link_to item.parent_item.title, item.parent_item}</li>"
        end
        html += "<li class=\"active\">#{truncate(item.title, length: 50)}</li>"\
          "</ol>"
      else
        html = "<ol class=\"breadcrumb\">"\
          "<li>#{link_to 'Home', root_path}</li>"\
          "<li>#{link_to 'Collections', repository_collections_path}</li>"\
          "<li>#{link_to item.collection.title, item.collection}</li>"
        if item.parent_item
          html += "<li>#{link_to item.parent_item.title, item.parent_item}</li>"
        end
        html += "<li class=\"active\">#{truncate(item.title, length: 50)}</li>"\
          "</ol>"
    end
    raw(html)
  end

  def results_breadcrumb(collection, context)
    if context == ItemsController::BrowseContext::BROWSING_COLLECTION
      html = "<ol class=\"breadcrumb\">"\
                "<li>#{link_to('Home', root_path)}</li>"\
                "<li>#{link_to('Collections', repository_collections_path)}</li>"\
                "<li>#{link_to(truncate(collection.title, length: 50), collection)}</li>"\
                "<li class=\"active\">Items</li>"\
              "</ol>"
      return raw(html)
    end
  end

end
