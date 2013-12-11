require 'spec_helper'
describe Condition do
  before(:all) do
    DB << "DROP TABLE IF EXISTS t_user"
    DB << "DROP TABLE IF EXISTS t_test"
    DB << "CREATE TABLE t_user(user_id BIGINT, user_name TEXT, login_ts TIMESTAMPTZ NOT NULL)"
    DB << "CREATE TABLE t_test(id BIGINT, name TEXT, flag BOOLEAN, ts TIMESTAMPTZ, iary BIGINT[], tary TEXT[], test_name TEXT NOT NULL)"

    converter = Condition::Reader::ConvertSheet.new(REDIS)
    converter.convert_dir(FILES, with_dir_name: false)
    converter.convert_dir(FILES)
  end

  it 'pre and post' do
    storage = Condition::Storage::Db.new(DB)
    param = Condition::Param.new(FILES + '/t_user.ods')
    default = Condition::Param.new(FILES + '/t_user.ods', 3)
    param.pre(storage, default)
    param = Condition::Param.new(FILES + '/t_user.ods', 1)
    param.post(storage)
    param = Condition::Param.new(FILES + '/t_user.ods', 4)
    expect { param.post(storage) }.to raise_error
    param = Condition::Param.new(FILES + '/t_user.ods', 5)
    expect { param.post(storage) }.to raise_error
  end

  it 'pre and params' do
    storage = Condition::Storage::Db.new(DB)
    param = Condition::Param.new(FILES + '/t_user.ods')
    default = Condition::Param.new(FILES + '/t_user.ods', 3)
    param.pre(storage, default)

    param = Condition::Param.new(FILES + '/t_user.ods', 2)
    item = default.item('t_user')
    ds = DB[:t_user].prepare(:insert, :insert_with_name, item.params.merge({user_id: :$user_id, user_name: :$user_name}))
    ds.call(item.value.merge(param.get('ins', 0)))

    list = DB["SELECT * FROM t_user"].all
    param.check('list', list)
    param.check('list', [{user_id: 1, user_name: "aaax"}])
  end

  it 'ref and json' do
    param = Condition::Param.new(FILES + '/t_user.ods', 2)
    param.check('ary', [{name: "a", val1: {a: "b", t: true, f: false}, val2: [{a: {c: "d"}}], val3: [], val4: nil, val5: {a: [1, 2, 3]}, val6: true, val7: false, val8: ''}])
  end

  it 'unmatch' do
    param = Condition::Param.new(FILES + '/t_user.ods', 2)
    lambda{param.check('unmatch', [{id: 1, name: "bbb", val: 456}])}.should raise_error
  end

  it 'present' do
    param = Condition::Param.new(FILES + '/t_user.ods', 2)
    param.check('present', [{val1: "a"}])
    lambda{param.check('present', [{val1: ""}])}.should raise_error
    lambda{param.check('present', [{val1: nil}])}.should raise_error
  end

  it 'regex' do
    param = Condition::Param.new(FILES + '/t_user.ods', 2)
    param.check('regex', [{val1: "abbbbbc"}])
    lambda{param.check('regex', [{val1: "ac"}])}.should raise_error
  end

  it 'mongo' do
    storage = Condition::Storage::Mongo.new(MONGO)
    param = Condition::Param.new(FILES + '/mongo.ods')
    default = Condition::Param.new(FILES + '/mongo.ods', 2)
    param.pre(storage, default)
    param = Condition::Param.new(FILES + '/mongo.ods', 1)
    param.post(storage)
  end

  it 'redis with set_reader' do
    reader = Condition::Reader::RedisReader.new(REDIS)
    Condition::Param.set_reader(reader)
    storage = Condition::Storage::Db.new(DB)
    param = Condition::Param.new('t_user_pre')
    default = Condition::Param.new('t_user_default')
    param.pre(storage, default)
    param = Condition::Param.new('t_user_post')
    param.post(storage)
    param = Condition::Param.new('t_user_post2')
    expect { param.post(storage) }.to raise_error
    param = Condition::Param.new('t_user_post3')
    expect { param.post(storage) }.to raise_error
  end

  it 'redis with reader parameter' do
    reader = Condition::Reader::RedisReader.new(REDIS)
    Condition::Param.set_reader(nil)

    storage = Condition::Storage::Db.new(DB)
    param = Condition::Param.new('files_t_user_pre', reader: reader)
    default = Condition::Param.new('files_t_user_default', reader: reader)
    param.pre(storage, default)
    param = Condition::Param.new('files_t_user_post', reader: reader)
    param.post(storage)
    param = Condition::Param.new('files_t_user_post2', reader: reader)
    expect { param.post(storage) }.to raise_error
    param = Condition::Param.new('files_t_user_post3', reader: reader)
    expect { param.post(storage) }.to raise_error
  end

  it 'eval' do
    param = Condition::Param.new(FILES + '/t_user.ods', 2)
    param.check('eval', [{
      val1: Time.now.hour,
      val2: "ab",
      val3: 3,
    }])
  end
end
