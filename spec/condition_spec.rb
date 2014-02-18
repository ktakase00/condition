require 'spec_helper'
describe Condition do
  before(:all) do
    DB << "DROP TABLE IF EXISTS t_user CASCADE"
    DB << "DROP TABLE IF EXISTS t_test CASCADE"
    DB << "CREATE TABLE t_user(user_id BIGINT, user_name TEXT, login_ts TIMESTAMPTZ NOT NULL)"
    DB << "CREATE TABLE t_test(id BIGINT, name TEXT, flag BOOLEAN, ts TIMESTAMPTZ, iary BIGINT[], tary TEXT[], test_name TEXT NOT NULL)"
    DB << "CREATE SCHEMA IF NOT EXISTS history"
    DB << "DROP TABLE IF EXISTS history.t_user CASCADE"
    DB << "CREATE TABLE history.t_user(user_id BIGINT, user_name TEXT, login_ts TIMESTAMPTZ NOT NULL)"

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
    param = Condition::Param.new(FILES + '/t_user.ods', 6)
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

    list = DB["SELECT * FROM t_user order by user_id"].all
    param.check('list', list)
    param.check('list', [
      {user_id: 1, user_name: "aaax"},
      {user_id: 2, user_name: "bbbx"},
      {user_id: 3, user_name: "cccx"},
      {user_id: 4, user_name: "ddd"},
    ])
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

  it 'now' do
    param = Condition::Param.new(FILES + '/t_user.ods', 2)
    t = Time.now
    t2 = Time.now - 24 * 3600
    val = param.get('now')
    expect(val[0][:val1].strftime("%Y%m%d")).to eq(t.strftime("%Y%m%d"))
    expect(val[0][:val2].strftime("%Y%m%d")).to eq(t2.strftime("%Y%m%d"))
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

  it 'redis read error' do
    reader = Condition::Reader::RedisReader.new(REDIS)
    Condition::Param.set_reader(nil)
    expect { Condition::Param.new('files_aaa', reader: reader) }.to raise_error("redis key name files_aaa not found")
  end

  it 'output count' do
    reader = Condition::Reader::RedisReader.new(REDIS)
    Condition::Param.set_reader(nil)
    param = Condition::Param.new('files_t_user_params', reader: reader)

    param.check('output_count', [{l: [{id: "1"}, {id: "2"}, {id: "3"}]}])
    expect { param.check('output_count', [{l: [{id: "1"}, {id: "2"}]}]) }.to raise_error
    expect { param.check('output_count', [{l: [{id: "1"}, {id: "2"}, {id: "3"}, {id: "4"}]}]) }.to raise_error
  end

  it 'options count' do
    reader = Condition::Reader::RedisReader.new(REDIS)
    Condition::Param.set_reader(nil)
    param = Condition::Param.new('files_t_user_params', reader: reader)

    item = param.item('options')
    expect(item.options.length).to eq(4)
  end

  it 'read sheet file' do
    REDIS.del("files2_param1_params")
    REDIS.del("files2_param2_params")
    converter = Condition::Reader::ConvertSheet.new(REDIS)
    converter.convert_dir(FILES2, file_name: 'param1.ods')
    expect(REDIS.get("files2_param1_params")).not_to be_nil
    expect(REDIS.get("files2_param2_params")).to be_nil
  end

  it 'name not found' do
    param = Condition::Param.new(FILES + '/t_user.ods', 2)
    expect { param.check('notexistsname', [{}]) }.to raise_error("notexistsname not found in param")
  end

  it 'many options' do
    param = Condition::Param.new(FILES + '/t_user.ods', 2)
    param.check('output_options', [
      {val1: "2", val2: "2", val3: "z"},
      {val1: "1", val2: "1", val3: "w"},
      {val1: "1", val2: "2", val3: "x"},
      {val1: "2", val2: "1", val3: "y"},
    ]) 
    param.check('output_options2', [
      {val1: "1", val2: "2", val3: "z"},
      {val1: "1", val2: "2", val3: "w"},
      {val1: "1", val2: "2", val3: "x"},
      {val1: "1", val2: "2", val3: "y"},
    ])
  end

  it 'output order' do
    param = Condition::Param.new(FILES + '/t_user.ods', 2)
    param.check('output_order', [
      {val1: "1", val2: "4"},
      {val1: "1", val2: "3"},
      {val1: "1", val2: "2"},
      {val1: "1", val2: "1"},
    ]) 

    expect do
      param.check('output_order', [
      {val1: "1", val2: "4"},
      {val1: "1", val2: "2"},
      {val1: "1", val2: "3"},
      {val1: "1", val2: "1"},
    ])
    end.to raise_error
  end

end
