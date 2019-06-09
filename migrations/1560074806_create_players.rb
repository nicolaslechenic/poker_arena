PokerArena::SequelDb.migrate(:create, :players) do |db|
  db.create_table :players do
    primary_key :id
    String :pseudo, unique: true, null: false
    String :password, null: false
  end
end
