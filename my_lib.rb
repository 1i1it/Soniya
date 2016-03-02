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
end

def time(&block) #to call: time { get '/u/ann-oates' }
  before = Time.now; yield; puts "Took: #{Time.now-before}"
end