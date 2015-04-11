require 'rails_helper'

FILES = File.dirname(__FILE__) + "/files"

RSpec.describe User, type: :model do
#  pending "add some examples to (or delete) #{__FILE__}"

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
end
