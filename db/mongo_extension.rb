class Mongo::Collection
  # read
  def get(params = {}) #get('id123') || get(email: 'bob@gmail.com')
    params = {_id: params} if !params.is_a? Hash
    get_many(params).last
  end

  def get_many(params = {}, opts = {})
    # you can limit amount of returned results by passing
    # required number in options. 100 by default
    opts[:limit] ||= 100 if !opts
    self.find(params, opts).to_a
  end

  def get_many_limited(params = {}, opts = {})
    opts[:limit] ||= 50 
    self.find(params, opts).to_a
  end

  def all(params = {}, opts = {})
    get_many(params, opts)
  end

  def first
    get_many.first
  end

  def last 
    get_many({}, sort: [{created_at: -1}]).first
  end

  def exists?(fields)
    get_many(fields, {projection: {_id:1}, limit: 1}).count > 0
  end

  def random(amount = 1, crit = {}) #random items
    arr = []
    amount.times { arr << find(crit).limit(1).skip(rand(find(crit).count)).first }
    amount == 1 ? arr[0] : arr
  end

  def num(crit = {}, opts = {})
    get_many(crit, opts).count
  end

  def search_anywhere(val, opts = {})
    crit = crit_any_field(self,val)
    get_many(crit)
  end

  def search_by(field, val, opts={})
    crit = {field => {"$regex" => Regexp.new(val, Regexp::IGNORECASE) } } 
    get_many(crit, opts)
  end

  def get_with(crit_or_id, other_coll, opts = {})
    join_mongo_colls(self, crit_or_id, other_coll, {})
  end

  #create
  def add(doc)
    doc[:_id] ||= nice_id
    doc[:created_at] = Time.now
    self.insert_one(doc)
    doc.hwia
  end

  def get_or_add(fields)
    get(fields) || add(fields)
  end

  #update
  def update_id(_id, fields = {}, opts = {}) #opts can be e.g. { :upsert => true }    
    fields[:updated_at] = Time.now
    opts[:return_document] = :after
    
    res = self.find_one_and_update({_id: _id}, {'$set' => fields}, opts)    
    return nil unless res
    {_id: _id}.merge(res).hwia
  end

  def set(crit, fields = {}, opts = {}) #opts['upsert'] == true to upsert     
    update(crit, {'$set' => fields.merge(updated_at: Time.now)}, opts)
  end
  
  def paginated_do(crit, opts = {}) #&block   
    find(crit).batch_size(1000).each {|item| yield(item)}
  end

  def fields
    mongo_coll_keys(self)
  end  
end #end Mongo class 
