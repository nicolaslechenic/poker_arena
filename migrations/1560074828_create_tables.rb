PokerArena::SequelDb.migrate(:create, :tables) do |db|
  db.create_table :tables do
    primary_key :id
    String :name, unique: true, null: false
  end
end