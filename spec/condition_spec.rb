require 'spec_helper'
describe Condition do
  describe Condition::Pre do
    it 'initialize' do
      pre = Condition::Pre.new(
        'postgres://localhost:5432/test?user=aoyagikouhei', 
        FILES + '/t_user.ods')
      pre.exec
    end
  end
end
