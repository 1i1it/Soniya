class Hash
  def just(firstItem, *args)
    args = (firstItem.is_a? Array) ? firstItem : args.unshift(firstItem)

    args = (args.map {|v| v.to_s}) + (args.map {|v| v.to_sym})
    self.slice(*args)
  end

  def hwia
    HashWithIndifferentAccess.new self
  end
end

class Array
  def mapo(field)
    self.map {|el| el[field]}
  end

  def hash_of_num_occurrences
    self.each_with_object(Hash.new(0)){|word,counts|counts[word]+=1}.sort_by{|k,v|v}.reverse.to_h
  end

end

def time(&block) #to call: time { get '/u/ann-oates' }
  before = Time.now; yield; puts "Took: #{Time.now-before}"
end

def to_numeric(n)
  return n.to_s.to_i if n.to_s == n.to_s.to_i.to_s  
  return n.to_s.to_f if n.to_s == n.to_s.to_f.to_s  
  n
end