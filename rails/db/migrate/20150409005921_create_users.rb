class CreateUsers < ActiveRecord::Migration
  def change
    create_table(:t_user, :id => false) do |t|
      t.bigint :user_id
      t.text :user_name
      t.timestamp :login_ts
    end

    sql = <<-EOS
      ALTER TABLE t_user ALTER COLUMN login_ts TYPE TIMESTAMPTZ
    EOS
    User.connection.execute(sql)
  end
end
