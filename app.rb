require 'sinatra'
require "sinatra/contrib"
require 'slim'
require 'sqlite3'

configure :production, :development do
  register Sinatra::Reloader
  set :port, 3000
end

get('/')  do
  slim(:start)
end 

get('/audios') do
  db = SQLite3::Database.new("db/audioBooks.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM audios")
  p result
  slim(:"audios/index",locals:{audioBooks:result})
end

get('/audios/new') do
  slim(:"audios/new")
end

post("/api/audios/:id/add") do 
  id = params[:id].to_i
  db = SQLite3::Database.new("db/audioBooks.db")
  db.results_as_hash = true
  result = db.execute("INSERT INTO audios (Title, AuthorId) VALUES (?, ?)", params[:audioBook], params[:authorId])
  redirect("/audios")
end

get("/api/audios/:id/delete") do 
  id = params[:id].to_i
  db = SQLite3::Database.new("db/audioBooks.db")
  db.results_as_hash = true
  result = db.execute("DELETE FROM audios WHERE AudioBookId = ?", id).first
  redirect("/audios")
end

get("/audios/:id/update") do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/audioBooks.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM audioBooks WHERE AudioBookId = ?",id).first
  slim(:"audios/update", locals:{result:result})
end

post("/api/audios/:id/update") do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/audioBooks.db")
  db.results_as_hash = true
  result = db.execute("UPDATE audioBooks SET Title = ?, AuthorId = ? WHERE AudioBookId = ?", params[:audioBook], params[:authorId], id)
  redirect("/audios")
end

get('/audios/:id') do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/audioBooks.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM audios WHERE audioId = ?",id).first
  puts result
  authorId = result[1]
  author = db.execute("SELECT * FROM authors WHERE AuthorID = ?", authorId).first
  slim(:"audios/show",locals:{result:result, author:author})
end

get("/signIn") do
  slim(:"signIn", locals:{})
end

