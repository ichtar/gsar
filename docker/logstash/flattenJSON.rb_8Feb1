def register(params)
    @field = params['field']
end

def filter(event)
  o = event.get(@field)
  temp={}
  name=""
  arrayOfEvents = Array.new()
  timestamp = event.get("timestamp")
  o.each do |k|
    k.each do |j,l|
      if l.is_a? String
        name=l
      else
        temp[j]=l
      end
    end
    temp.each do |p,g|
      arrayOfEvents.push({"nic" => name, "key" => p, "value" => g, "timestamp" => timestamp})
    end
    #event.set(name,temp)
    #event.tag(name)
  end
  event.remove(@field)
  event.set("net-dev",arrayOfEvents)
  return [event]
end
