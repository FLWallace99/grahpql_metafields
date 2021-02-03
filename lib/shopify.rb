 
require 'shopify_api'


class Shopify

  def initialize(shop_name)
    shop_url = "https://#{ENV["#{shop_name}_api_key"]}:#{ENV["#{shop_name}_password"]}@#{ENV["#{shop_name}_shop_name"]}.myshopify.com/admin"
    puts shop_url.inspect
    ShopifyAPI::Base.site = shop_url
    ShopifyAPI::Base.api_version = '2020-04'
    ShopifyAPI::Base.timeout = 180
    ShopifyAPI::GraphQL.initialize_clients
  end
end