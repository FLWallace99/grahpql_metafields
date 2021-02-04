require 'dotenv'
Dotenv.load
require 'active_record'
require 'shopify_api'
require 'sinatra/activerecord/rake'
require 'activerecord-import'

require_relative 'product_metafields'



load 'active_record/railties/databases.rake'

load 'shopify_api/graphql/task.rake'

namespace :pull_metafields do
    
    desc 'pull metafields of all products from Shopify store'
    task :fetch_metafields do |t|
        ShopifyClient::ProductMeta.new.get_info_shopify
    end


end