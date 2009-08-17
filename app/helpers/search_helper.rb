module SearchHelper
  def total_and_pageview(descriptor, total_hits, page)
    bottom = (page - 1) * DEFAULT_SEARCH_PAGE_SIZE + 1
    top = (page * DEFAULT_SEARCH_PAGE_SIZE) > total_hits ? total_hits : (page * DEFAULT_SEARCH_PAGE_SIZE)

    "Found <b>#{number_with_delimiter(total_hits)}</b> #{descriptor}. Displaying <b>#{bottom}-#{top}</b>."
  end
end
