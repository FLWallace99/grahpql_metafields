require 'dotenv'
Dotenv.load

Dir[File.join(__dir__, 'lib', '*.rb')].each { |file| require file }


module ShopifyClient
  class ProductMeta
    def initialize
        shop_name = "elliestaging"
        Shopify.new(shop_name)
        @shop = ShopifyAPI::Shop.current

    end

    def get_info_shopify

      my_prods_list = run_graphql_query
      my_cursor = my_prods_list.last.cursor
      puts my_cursor
      while my_cursor.present?
      my_prods_list = run_graphql_subsequent(my_cursor)
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