module ResourcesHelper
  def available_colors
    return {
      'White' => 'ffffff',
      'Black' => '000000',
      'Red' => 'ff0000',
      'Blue' => '0000ff',
      'Green' => '008000',
      'Light Blue' => '3167cb',
      'Yellow' => 'ffff00',
      'Gray' => 'cccccc'
    }
  end
  
  def trend_item_types
    item_types = {
      "Most Viewed Bills" => 'viewed-bill',
      "Most Viewed Senators" => 'viewed-sen',
      "Most Viewed Representatives" => 'viewed-rep',
      "Most Viewed Committees" => 'viewed-committee',
      "Most Viewed Issues" => 'viewed-issue',
      "Bills Most In The News" => 'news-bill',
      "Bills Most In The Blogs" => 'blog-bill',
      "Senators Most In The News" => 'news-sen',
      "Senators Most In The Blogs" => 'blog-sen',
      "Representatives Most In The News" => 'news-rep',
      "Representatives Most In The Blogs" => 'blog-rep',
      "Top Search Terms" => 'topsearches'
    }
    
    return item_types.sort {|a,b| a[1]<=>b[1]}
  end
end