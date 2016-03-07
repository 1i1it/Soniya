Mongo::Logger.logger.level = Logger::WARN 

mongodb_db_name = $app_name 
mongodb_db_name = 'yesno_prod_backup'
DB_URI = ENV["MONGOLAB_URI"] || "mongodb://localhost:27017/#{mongodb_db_name}"

$mongo = Mongo::Client.new(DB_URI).database
$posts = $mongo.collection('posts')

def page_mongo(collection, crit, opts)
  default_limit = 20
  sort = Array(opts[:sort])

  if opts[:limit] && opts[:skip] 
    limit     = opts[:limit].to_i
    skip      = opts[:skip].to_i
  elsif opts[:page]
    page_num  = opts[:page].to_i
    page_num  = 1 if page_num == 0  
    page_size = opts[:page_size] ? opts[:page_size].to_i : default_limit
    
    limit     = page_size
    skip      = (page_num-1) * limit
  else
    limit     = default_limit
    skip      = 0
  end 
  
  items  = collection.find(crit).limit(limit).skip(skip).sort(sort).to_a
  done   = (skip + limit) >= collection.find(crit).count
  return items, done
end

