require_relative './configuration/initializers/sequel'

namespace :db do
  desc 'Migrate the database'
  task :migrate do
    Dir['./migrations/*.rb'].each { |file| require file }
  end

  desc 'Populate database'
  task :seed do
    require_relative './lib/poker_arena'
    %w[Tatooine Moon Earth Nostromo].each do |name|
      PokerArena::Table.create(name: name)
    end
  end
end
