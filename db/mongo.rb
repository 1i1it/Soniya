Mongo::Logger.logger.level = Logger::WARN 

mongodb_db_name = $app_name 
#mongodb_db_name = 'yesno_prod_backup'
DB_URI = ENV["MONGODB_URI"] || "mongodb://localhost:27017/#{mongodb_db_name}"

$mongo = Mongo::Client.new(DB_URI).database

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
rescue => e 
  []
end

def get_unique_slug(coll, field, val, crit = {})
    # gets a unique slug based on 'val' for field 'field'.
    # $users.get_unique_slug('username','Sella Rafaeli') => 'sella-rafaeli' or 'sella-rafaeli-2'
    slug  = val.to_slug.normalize.to_s.slice(0,200)
    !coll.exists?(crit.merge!({field.to_s => slug}))       ? slug      :
    !coll.exists?(crit.merge!({field.to_s => slug+"-1"}))  ? slug+"-1" :    
    !coll.exists?(crit.merge!({field.to_s => slug+"-2"}))  ? slug+"-2" :    
    !coll.exists?(crit.merge!({field.to_s => slug+"-3"}))  ? slug+"-3" :    
    !coll.exists?(crit.merge!({field.to_s => slug+"-4"}))  ? slug+"-4" :    
    !coll.exists?(crit.merge!({field.to_s => slug+"-5"}))  ? slug+"-5" :    
    !coll.exists?(crit.merge!({field.to_s => slug+"-6"}))  ? slug+"-6" :    
    slug+"-"+rand(1000000).to_s
end  

def crit_any_field(coll, val) # $
  coll_keys = mongo_coll_keys(coll)
  return {} unless coll_keys.any?
  
  {"$or" => coll_keys.map { |f| {f => {"$regex" => Regexp.new(val, Regexp::IGNORECASE) }}} }
end

# join_colls($users,123/{name: 'joe'},[$posts,$msgs])
def join_mongo_colls(coll1, id, colls)
  item   = coll1.find(_id: id).first # {"_id"=>123, "name"=>"Joe"}
  fkey   = coll1.name[0..-2]+"_id" # "user_id"
  joined = colls.map { |coll| coll.find(fkey => item['_id']).to_a } # [posts, messages]
  return joined.unshift(item) # [user, posts, messages]
end
