# Basic requires
require 'rubygems'
require 'java'
require 'jdbc/hsqldb'
require 'jruby/core_ext'

# Our requires
require 'hibernate'

Hibernate.dialect = Hibernate::Dialects::HSQL
Hibernate.current_session_context_class = "thread"

Hibernate.connection_driver_class = "org.hsqldb.jdbcDriver"
Hibernate.connection_url = "jdbc:hsqldb:file:jibernate"
Hibernate.connection_username = "sa"
Hibernate.connection_password = ""
Hibernate.properties["hbm2ddl.auto"] = "update"

class Event
  extend Hibernate::Model
  hibernate_attr :id => :long, :title => :string, :date => :date
  hibernate!
end

Hibernate.add_model "Event.hbm.xml"

Hibernate.tx do |session|
  # Hack for HSQLDB's write delay
  session.createSQLQuery("SET WRITE_DELAY FALSE").execute_update

  case ARGV[0]
  when /store/
    # Create event and store it
    event = Event.new
    event.title = ARGV[1]
    event.date = java.util.Date.new
    
    session.save(event)
    puts "Stored!"
  when /list/
    # List all events
    list = session.create_query('from Event').list
    puts "Listing all events:"
    list.each do |evt|
      puts <<EOS
  id: #{evt.id}
    title: #{evt.title}
    date: #{evt.date}"
EOS
    end
  else
    puts "Usage:\n\tstore <title>\n\tlist"
  end
end