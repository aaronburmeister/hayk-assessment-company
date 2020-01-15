require 'sqlite3'
require 'pry'
require_relative "./app"

# create database
DB = {:conn => SQLite3::Database.new('./company.db')}

# create table in database
Company.create_table

# Load all saved files - takes all rows from the company db
# and loads Company instances from all of them.
Company.all

binding.pry