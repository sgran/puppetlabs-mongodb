require 'spec_helper'

describe Puppet::Type.type(:mongodb_user).provider(:mongodb) do

  let(:resource) { Puppet::Type.type(:mongodb_user).new(
    { :ensure        => :present,
      :name          => 'new_user',
      :database      => 'new_database',
      :password_hash => 'pass',
      :password      => 'pass',
      :roles         => ['role1', 'role2'],
      :provider      => described_class.name
    }
  )}

  let(:provider) { resource.provider }

  describe 'version' do
    it 'returns a version' do
      provider.expects(:mongo).at_least(1).returns('MongoDB shell version: 2.6.0')
      provider.version.should == 260
    end
  end

  describe 'create' do
    it 'creates a user' do
      provider.expects(:mongo)
      provider.stubs(:version).returns(248)
      provider.create
    end
    it 'creates a user in 2.6' do
      provider.expects(:mongo)
      provider.stubs(:version).returns(262)
      provider.create
    end
  end

  describe 'destroy' do
    it 'removes a user' do
      provider.expects(:mongo)
      provider.stubs(:version).returns(248)
      provider.destroy
    end
    it 'removes a user in 2.6' do
      provider.expects(:mongo)
      provider.stubs(:version).returns(262)
      provider.destroy
    end
  end

  describe 'exists?' do
    it 'checks if user exists' do
      provider.expects(:mongo).at_least(2).returns("1")
      provider.stubs(:version).returns(248)
      provider.exists?.should eql true
    end
    it 'checks if user exists in 2.6' do
      provider.expects(:mongo).at_least(2).returns("1")
      provider.stubs(:version).returns(262)
      provider.exists?.should eql true
    end
  end

  describe 'password_hash' do
    it 'returns a password_hash' do
      provider.expects(:mongo).returns("pass\n")
      provider.stubs(:version).returns(248)
      provider.password_hash.should == "pass"
    end
    it 'returns a password_hash in 2.6' do
      provider.expects(:mongo).returns("pass\n")
      provider.stubs(:version).returns(262)
      provider.password_hash.should == "pass"
    end
  end

  describe 'password_hash=' do
    it 'changes a password_hash' do
      provider.expects(:mongo)
      provider.stubs(:version).returns(248)
      provider.password_hash=("newpass")
    end
    it 'changes a password_hash in 2.6' do
      provider.expects(:mongo)
      provider.stubs(:version).returns(262)
      provider.password_hash=("newpass")
    end
  end

  describe 'roles' do
    it 'returns a sorted roles' do
      provider.expects(:mongo).returns("role2,role1\n")
      provider.stubs(:version).returns(248)
      provider.roles.should == ['role1','role2']
    end
    it 'returns a sorted roles in 2.6' do
      provider.expects(:mongo).returns('[{"role": "role2","db": "new_database"},{"role": "role1", "db": "new_database"}]')
      provider.stubs(:version).returns(262)
      provider.roles.should == ['role1','role2']
    end
  end

  describe 'roles=' do
    it 'changes a roles' do
      provider.expects(:mongo)
      provider.stubs(:version).returns(248)
      provider.roles=(['role3','role4'])
    end
    it 'changes a roles in 2.6' do
      provider.expects(:mongo)
      provider.stubs(:version).returns(262)
      provider.roles=(['role3','role4'])
    end
  end

end
