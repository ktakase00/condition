require 'spec_helper'
describe Condition do
  it 'pre and post' do
    pre = Condition::Pre.new(FILES + '/t_user.ods')
    pre.exec(DB)
    post = Condition::Post.new(FILES + '/t_user.ods', 1)
    post.exec(DB)
  end
end
