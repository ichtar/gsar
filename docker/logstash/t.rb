var="[ {:wq


event.get("net-dev").each do |k, v|
   k[v].each do |j, q|
     if j[q].is_a? String
       event.set("net-dev-"+j[q],v)
     end
   end
 end
 event.remove("net-dev")
        '
