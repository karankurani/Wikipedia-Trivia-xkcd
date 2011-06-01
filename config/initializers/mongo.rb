MongoMapper.connection = Mongo::Connection.new('dbh10.mongolab.com', 27107)
MongoMapper.database = "wikipedia-first"
MongoMapper.database.authenticate('karankurani', 'verysecretpassword')

if defined?(PhusionPassenger)
   PhusionPassenger.on_event(:starting_worker_process) do |forked|
     MongoMapper.connection.connect if forked
   end
end
