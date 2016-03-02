class Mongo::Collection

  MAX_SLUG_SIZE = 200 #arbitrary, just to keep it decent

  #get('id123') || get(email: 'bob@gmail.com')
  def find_one(params, field = :_id)
    return nil if params.nil? #to avoid mistakes      
    return self.find(params).first if params.is_a? Hash

    find_one((field.to_s) => params)
  end
  alias_method :get, :find_one

  def find_all(params = {})
    self.find(params).to_a
  end

  def add(doc)
    doc[:_id] ||= nice_id
    doc[:created_at] = Time.now
    self.insert_one(doc)
    doc.hwia
  end

  def first
    self.find.first
  end

  def last 
    self.find({}, sort: [{created_at: -1}]).first
  end

  #update_one
  def update_id(_id, fields, opts = {})
    #opts can be e.g. { :upsert => true }
    fields[:updated_at] = Time.now
    opts[:return_document] = :after
    
    res = self.find_one_and_update({_id: _id}, {'$set' => fields}, opts)    
    {_id: _id}.merge(res).hwia
  end

  def set(crit, fields, opts = {})
    #set opts['upsert'] == true to upsert 
    fields[:updated_at] = Time.now
    update(crit, {'$set' => fields}, opts)
  end

  def exists?(fields)
    self.find(fields, {projection: {_id:1}}).limit(1).count > 0
  end

  def get_or_create(fields)
    find_one(fields) || add(fields)
  end

  def random(amount = 1, crit = {}) #random items
    arr = []
    amount.times { arr << find(crit).limit(1).skip(rand(find(crit).count)).first }
    amount == 1 ? arr[0] : arr
  end

  # gets a unique slug based on 'val' for field 'field'.
  # i.e. $users.get_unique_slug('username','Sella Rafaeli') => 'sella-rafaeli' or 'sella-rafaeli-2'
  def get_unique_slug(field, val, crit = {})
    slug  = val.to_slug.normalize.to_s.slice(0,200)
    !exists?(crit.merge!({field.to_s => slug}))       ? slug      :
    !exists?(crit.merge!({field.to_s => slug+"-1"}))  ? slug+"-1" :    
    !exists?(crit.merge!({field.to_s => slug+"-2"}))  ? slug+"-2" :    
    !exists?(crit.merge!({field.to_s => slug+"-3"}))  ? slug+"-3" :    
    !exists?(crit.merge!({field.to_s => slug+"-4"}))  ? slug+"-4" :    
    !exists?(crit.merge!({field.to_s => slug+"-5"}))  ? slug+"-5" :    
    !exists?(crit.merge!({field.to_s => slug+"-6"}))  ? slug+"-6" :    
    slug+"-"+rand(1000000).to_s
  end  

  def paginated_do(crit, opts = {}) #&block   
    find(crit).batch_size(1000).each {|item| yield(item)}
  end

  def nice_id
    #return BSON::ObjectId.new.to_s
    #return self.name + "_" + BSON::ObjectId.new.to_s
    #return BSON::ObjectId.new.to_s.to_i(16).base62_encode #.base62_decode to reverse 
    #return rand(Time.now.to_i*100).to_s(36)
    SecureRandom.urlsafe_base64(7,false)
  end
end #end Mongo class 
