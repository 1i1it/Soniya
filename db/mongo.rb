Mongo::Logger.logger.level = Logger::WARN 

mongodb_db_name = $app_name 
#mongodb_db_name = 'yesno_prod_backup'
DB_URI = ENV["MONGOLAB_URI"] || "mongodb://localhost:27017/#{mongodb_db_name}"

$mongo = Mongo::Client.new(DB_URI).database
$posts = $mongo.collection('posts')
$mongo_data = {}
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

def mongo_coll_keys(coll)
  coll_name = coll.name
  key = "#{coll_name}_collection_fields"  
  if !$mongo_data[key]  
    opts = {
      mapreduce: coll_name,
      map: "function() { for (var key in this) { emit(key, null); }}",    
      reduce: "function(key, stuff) { return null; }", 
      out: {inline: 1}
    }
    mongo_results    = $mongo.command(opts)
    $mongo_data[key] = mongo_results.to_a[0]['results'].map { |doc| doc['_id'] }
  end
  $mongo_data[key]
end

def crit_any_field(coll, val)
  {"$or" => mongo_coll_keys(coll).map { |f| {f => {"$regex" => Regexp.new(val, Regexp::IGNORECASE) }}} }
end