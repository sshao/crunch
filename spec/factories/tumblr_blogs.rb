FactoryGirl.define do
  factory :tumblr_blog do
    username "arrow"

    initialize_with { TumblrBlog.new(username) }
  end

  factory :invalid_tumblr_blog, parent: :tumblr_blog do
    username "idontexist"
  end
end
