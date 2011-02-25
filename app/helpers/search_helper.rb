module SearchHelper
  def total_and_pageview(descriptor, total_hits, page)
    bottom = (page - 1) * Settings.default_search_page_size + 1
    top = (page * Settings.default_search_page_size) > total_hits ? total_hits : (page * Settings.default_search_page_size)

    "Found <b>#{number_with_delimiter(total_hits)}</b> #{descriptor}. Displaying <b>#{bottom}-#{top}</b>."
  end
end
