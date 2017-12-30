require "../src/**"

config = Crynamo::Configuration.new("foo", "secret", "us-east-1", "http://localhost:8000")
db = Crynamo::Client.new(config)

# Assuming that you have a table named "pets"
db.put("pets", {name: "Thor", age: 100, family_friendly: false})
db.put("pets", {name: "Scooby-Doo", age: 9, family_friendly: true, nickname: "Scooby"})

# Assuming you have a primary key named "name"
data = db.get("pets", {name: "Scooby-Doo"})

puts "Found pet:"
puts "Name: #{data["name"]}"
puts "Age: #{data["age"]}"
puts "Family Friendly?: #{data["family_friendly"]}"
puts "Nickname: #{data["nickname"]}"
