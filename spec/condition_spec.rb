require 'spec_helper'
describe Condition do
  before(:all) do
    DB << "DROP TABLE IF EXISTS t_user"
    DB << "DROP TABLE IF EXISTS t_test"
    DB << "CREATE TABLE t_user(user_id BIGINT, user_name TEXT, login_ts TIMESTAMPTZ NOT NULL)"
    DB << "CREATE TABLE t_test(id BIGINT, name TEXT, flag BOOLEAN, ts TIMESTAMPTZ, iary BIGINT[], tary TEXT[], test_name TEXT NOT NULL)"
  end
  
  it 'pre and post' do
    param = Condition::Param.new(FILES + '/t_user.ods')
    default = Condition::Param.new(FILES + '/t_user.ods', 3)
    param.pre(DB, default)
    param = Condition::Param.new(FILES + '/t_user.ods', 1)
    param.post(DB)
  end

  it 'pre and params' do
    param = Condition::Param.new(FILES + '/t_user.ods')
    default = Condition::Param.new(FILES + '/t_user.ods', 3)
    param.pre(DB, default)

    param = Condition::Param.new(FILES + '/t_user.ods', 2)
    item = default.item('t_user')
    ds = DB[:t_user].prepare(:insert, :insert_with_name, item.params.merge({user_id: :$user_id, user_name: :$user_name}))
    ds.call(item.value.merge(param.get('ins', 0)))

    list = DB["SELECT * FROM t_user"].all
    #p param.get('ary')
    param.check('list', list)
    param.check('list', [{user_id: 1, user_name: "aaax"}])
    param.check('ary', [{name: "a", val1: {a: "b"}, val2: [{a: {c: "d"}}], val3: [], val4: nil}])
  end

  it 'unmatch' do
    param = Condition::Param.new(FILES + '/t_user.ods', 2)
    lambda{param.check('unmatch', [{id: 1, name: "bbb", val: 456}])}.should raise_error
  end
end
