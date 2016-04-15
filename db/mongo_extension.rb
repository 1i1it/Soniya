class Mongo::Collection
  # read
  def get(params = nil) #get('id123') || get(email: 'bob@gmail.com')
    params.present? ? self.find_one(params) : random 
  end

  def all(params = {}, opts = {})
    self.find(params).to_a
  end

  def first
    self.find.first
  end

  def last 
    self.find({}, sort: [{created_at: -1}]).first
  end

  def exists?(fields)
    self.find(fields, {projection: {_id:1}}).limit(1).count > 0
  end

  def random(amount = 1, crit = {}) #random items
    arr = []
    amount.times { arr << find(crit).limit(1).skip(rand(find(crit).count)).first }
    amount == 1 ? arr[0] : arr
  end

  def num(crit = {})
    self.find(crit).count
  end

  #create
  def add(doc)
    data = doc.merge(_id: nice_id, created_at: Time.now)
    self.insert_one(data)
    data.hwia
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
