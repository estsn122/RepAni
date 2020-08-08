FactoryBot.define do
  factory :anime do
    sequence(:title) { |n| "title_#{n}" }
    broadcast_datetime { DateTime.now }
    air_time { 30 }
    public_url { 'http://example.com' }
    sequence(:twitter_account) { |n| "test_screen_name_#{n}" }
    sequence(:twitter_hash_tag) { |n| "test_hash_tag_#{n}" }
  end
end
