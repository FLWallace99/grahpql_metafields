# Example Demo of Getting Metafields from Shopify via Graphql

- [x] Sample framework set up, code will work
- [ ] Detailed instructions on how to run this including dumping Shopify Schema
- [ ] Example code of saving metafield to database with matching product_id
- [ ] Sample .env file for easy set up

### Notes 
You must run the job to set up the schema locally otherwise no calls to GraphQL will run. Please note that HEREDOC interpolation will NOT run in setting up the call for the query if the HEREDOC is enclosed in quotes. The initial HEREDOC has quotes and nothing put in there will be interpolated. The subsequent example does NOT HAVE QUOTES (look at it carefully) so your standard ruby interpolation #{my_variable} will work.

```ruby
rake shopify_api:graphql:dump 
```
See documentation to run the job

Out of the box your plain old ruby script (which is often where I run jobs that just need to ETL) won't work with Graphql. Do the following in your rake task to make them run

```ruby
load 'active_record/railties/databases.rake'

load 'shopify_api/graphql/task.rake'

```

Your project should look like this:

![Your Project](https://github.com/FLWallace99/grahpql_metafields/blob/master/images/your_project.png)

