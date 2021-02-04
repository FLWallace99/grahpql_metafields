require 'dotenv'
Dotenv.load
require 'active_record'
require 'sinatra/activerecord'

Dir[File.join(__dir__, 'lib', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'models', '*.rb')].each { |file| require file }


module ShopifyClient
  class ProductMeta
    def initialize
        shop_name = "elliestaging"
        Shopify.new(shop_name)
        @shop = ShopifyAPI::Shop.current

    end

    def get_info_shopify

      ProductMetafield.delete_all
      ActiveRecord::Base.connection.reset_pk_sequence!('product_metafields')

      my_prods_list = run_graphql_query
      my_cursor = my_prods_list.last.cursor
      my_prods_list.each_with_object([]) do |product|
        #puts product.node.legacy_resource_id
        #puts product.node.title
        temp_product_id = product.node.legacy_resource_id
        temp_product_metafield_key = ""
        temp_product_metafield_value = ""
        my_meta = product.node.metafields&.edges.each_with_object([]) do |mym|
            puts mym.node.key
            puts "product_collection: #{mym.node.value}"
            temp_product_metafield_key = mym.node.key
            temp_product_metafield_value = mym.node.value
        end
        if temp_product_metafield_value != ""
        ProductMetafield.create(product_id: temp_product_id, metafield_key: temp_product_metafield_key, metafield_value: temp_product_metafield_value)
        end
    end

      puts my_cursor
      while my_cursor.present?
      my_prods_list = run_graphql_subsequent(my_cursor)
      my_cursor = my_prods_list.last.cursor
      my_prods_list.each_with_object([]) do |product|
        #puts product.node.legacy_resource_id
        #puts product.node.title
        temp_product_id = product.node.legacy_resource_id
        temp_product_metafield_key = ""
        temp_product_metafield_value = ""
        my_meta = product.node.metafields&.edges.each_with_object([]) do |mym|
            puts mym.node.key
            puts "product_collection: #{mym.node.value}"
            temp_product_metafield_key = mym.node.key
            temp_product_metafield_value = mym.node.value
        end
        if temp_product_metafield_value != ""
        ProductMetafield.create(product_id: temp_product_id, metafield_key: temp_product_metafield_key, metafield_value: temp_product_metafield_value)
        end
    end
      break if my_prods_list.nil?
      my_cursor = my_prods_list.last&.cursor
      
      end


    end


    def run_graphql_query
        puts "Starting Running GraphQL to get specific product metafields"
        

        query = ShopifyAPI::GraphQL.client.parse <<-'GRAPHQL'
            {
                products(first: 20, query: "") {
                    edges {
                      cursor
                      node {
                        legacyResourceId
                        title
                        metafields(first: 10, namespace: "ellie_order_info") {
                          edges {
                            node {
                              value
                              key
                            }
                            
                          }
                        }
                      }
                      
                    }
                    pageInfo {
                        hasNextPage
                        hasPreviousPage
                      }
                  }
             }
        GRAPHQL

        
        results = ShopifyAPI::GraphQL.client.query(query)
        puts results.data.products.edges.inspect
        temp_stuff = results.data.products.edges
        puts results.inspect
        puts "-------"
        temp_stuff.each_with_object([]) do |product|
            puts product.node.legacy_resource_id
            puts product.node.title
            my_meta = product.node.metafields&.edges.each_with_object([]) do |mym|
                puts mym.node.key
                puts "product_collection: #{mym.node.value}"
            end
        end

        return results.data.products.edges

        
        
        


    end

    def run_graphql_subsequent(my_cursor)
      

      newquery = ShopifyAPI::GraphQL.client.parse <<-GRAPHQLNEW
            {
                products(first: 20, query: "", after: \"#{my_cursor}\" ) {
                    edges {
                      cursor
                      node {
                        legacyResourceId
                        title
                        metafields(first: 10, namespace: "ellie_order_info") {
                          edges {
                            node {
                              value
                              key
                            }
                            
                          }
                        }
                      }
                      
                    }
                    pageInfo {
                        hasNextPage
                        hasPreviousPage
                      }
                  }
             }
        GRAPHQLNEW
        

        results = ShopifyAPI::GraphQL.client.query(newquery)
        puts results.inspect
        puts results.data.products.edges.inspect
        temp_stuff = results.data.products.edges
        puts results.inspect
        puts "-------"
        temp_stuff.each_with_object([]) do |product|
            puts product.node.legacy_resource_id
            puts product.node.title
            my_meta = product.node.metafields&.edges.each_with_object([]) do |mym|
                puts mym.node.key
                puts "product_collection: #{mym.node.value}"
            end
        end
        sleep 20 if results.extensions['cost']['throttleStatus']['currentlyAvailable'].to_i < 522

        return results.data.products.edges



    end

    
        

      

  end
end