require 'spec_helper'
describe Condition do
  before(:all) do
    DB << "CREATE TABLE IF NOT EXISTS t_user(user_id BIGINT, user_name TEXT)"
    DB << "CREATE TABLE IF NOT EXISTS t_test(id BIGINT, name TEXT, flag BOOLEAN, ts TIMESTAMPTZ, iary BIGINT[], tary TEXT[])"
  end
  
  it 'pre and post' do
    pre = Condition::Pre.new(FILES + '/t_user.ods')
    pre.exec(DB)
    post = Condition::Post.new(FILES + '/t_user.ods', 1)
    post.exec(DB)
  end
end
