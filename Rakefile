namespace :db do
  desc 'Migrate the database'
  task :migrate do
    Dir['./migrations/*.rb'].each { |file| require file }
  end
end
