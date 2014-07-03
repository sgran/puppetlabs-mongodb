Puppet::Type.type(:mongodb_user).provide(:mongodb) do

  desc "Manage users for a MongoDB database."

  defaultfor :kernel => 'Linux'

  commands :mongo => 'mongo'
  require 'json'

  VERSION = mongo('--version')[23..-1].split('.').join().to_i

  def block_until_mongodb(tries = 10)
    begin
      mongo('--quiet', '--eval', 'db.getMongo()')
    rescue
      debug('MongoDB server not ready, retrying')
      sleep 2
      retry unless (tries -= 1) <= 0
    end
  end

  def create
    if VERSION > 260
      mongo(@resource[:database], '--eval', "db.createUser({user:\"#{@resource[:name]}\", pwd:\"#{@resource[:password]}\", roles: #{@resource[:roles].inspect}})")
    elsif VERSION > 240
      mongo(@resource[:database], '--eval', "db.system.users.insert({user:\"#{@resource[:name]}\", pwd:\"#{@resource[:password_hash]}\", roles: #{@resource[:roles].inspect}})")
    end
  end

  def destroy
    if VERSION > 260
      mongo(@resource[:database], '--quiet', '--eval', "db.dropUser(\"#{@resource[:name]}\")")
    elsif VERSION > 240
      mongo(@resource[:database], '--quiet', '--eval', "db.removeUser(\"#{@resource[:name]}\")")
    end
  end

  def exists?
    block_until_mongodb(@resource[:tries])
    if VERSION > 260
      mongo('admin', '--quiet', '--eval', "db.system.users.find({user:\"#{@resource[:name]}\"}).count()").strip.eql?('1')
    elsif VERSION > 240
      mongo(@resource[:database], '--quiet', '--eval', "db.system.users.find({user:\"#{@resource[:name]}\"}).count()").strip.eql?('1')
    end
  end

  def password
    pass = mongo('admin', '--quiet', '--eval', "db.system.users.findOne({user:\"#{@resource[:name]}\"})[\"credentials\"][\"MONGODB-CR\"]").strip
    if pass == @resource[:password_hash]
      return @resource[:password]
    end
    pass
  end

  def password=
    mongo('admin', '--quiet', '--eval', "db.updateUser(\"#{@resource[:name]}\", { pwd: \"#{@resource[:password]}\"})")
  end

  def password_hash
    if VERSION > 260
      mongo('admin', '--quiet', '--eval', "db.system.users.findOne({user:\"#{@resource[:name]}\"})[\"credentials\"][\"MONGODB-CR\"]").strip
    elsif VERSION > 240
      mongo(@resource[:database], '--quiet', '--eval', "db.system.users.findOne({user:\"#{@resource[:name]}\"})[\"pwd\"]").strip
    end
  end

  def password_hash=(value)
    if VERSION > 260
      mongo('admin', '--quiet', '--eval', "db.system.users.update({user:\"#{@resource[:name]}\"}, { $set: {pwd:\"#{value}\"}})")
    elsif VERSION > 240
      mongo(@resource[:database], '--quiet', '--eval', "db.system.users.update({user:\"#{@resource[:name]}\"}, { $set: {pwd:\"#{value}\"}})")
    end
  end

  def roles
    if VERSION > 260
      JSON.load(mongo('admin', '--quiet', '--eval', "printjson(db.system.users.findOne({user:\"#{@resource[:name]}\"})[\"roles\"])").strip).collect{ |x| x['role'] if x['db'] == @resource[:database] }
    elsif VERSION > 240
      mongo(@resource[:database], '--quiet', '--eval', "db.system.users.findOne({user:\"#{@resource[:name]}\"})[\"roles\"]").strip.split(",").sort
    end
  end

  def roles=(value)
    if VERSION > 260
      roles = JSON.load(@resource[:roles].inspect).map{ |x| {"db" => @resource[:database], "role" => x} }.to_json()
      mongo('admin', '--quiet', '--eval', "db.updateUser(\"#{@resource[:name]}\", { roles: #{roles}})")
    elsif VERSION > 240
      mongo(@resource[:database], '--quiet', '--eval', "db.system.users.update({user:\"#{@resource[:name]}\"}, { $set: {roles: #{@resource[:roles].inspect}}})")
    end
  end

end
