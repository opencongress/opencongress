module RedClothCommentsFormatter
  include RedCloth::Formatters::Base
  include RedCloth::Formatters::HTML
  
    def after_transform(text)
      text.chomp!
      clean_html(text, ALLOWED_TAGS)
    end
    ALLOWED_TAGS = {
        'a' => ['href', 'title'],
        'br' => nil,
        'p' => nil,
        'i' => nil,
        'u' => nil,
        'b' => nil,
        'pre' => nil,
        'kbd' => nil,
        'code' => nil,
        'cite' => nil,
        'strong' => nil,
        'em' => nil,
        'ins' => nil,
        'sup' => nil,
        'sub' => nil,
        'del' => nil,
        'ol' => nil,
        'ul' => nil,
        'li' => nil,
        'blockquote' => nil
      }
end

module RedCloth
  class TextileDoc
    def to_comments_html( *rules )
      apply_rules(rules)
  
      to(RedClothCommentsFormatter)
    end
  end
end