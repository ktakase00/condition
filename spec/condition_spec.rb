require 'spec_helper'
describe Condition do
  before(:all) do
    DB << "CREATE TABLE IF NOT EXISTS t_user(user_id BIGINT, user_name TEXT)"
    DB << "CREATE TABLE IF NOT EXISTS t_test(id BIGINT, name TEXT, flag BOOLEAN, ts TIMESTAMPTZ, iary BIGINT[], tary TEXT[])"
  end
  
  it 'pre and post' do
    param = Condition::Param.new(FILES + '/t_user.ods')
    param.pre(DB)
    param = Condition::Param.new(FILES + '/t_user.ods', 1)
    param.post(DB)
  end

  it 'pre and params' do
    param = Condition::Param.new(FILES + '/t_user.ods')
    param.pre(DB)

    param = Condition::Param.new(FILES + '/t_user.ods', 2)
    ds = DB[:t_user].prepare(:insert, :insert_with_name, {user_id: :$user_id, user_name: :$user_name})
    ds.call(param.get_one('ins'))

    list = DB["SELECT * FROM t_user"].all
    param.check('list', list)
  end
end
