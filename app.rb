require 'sinatra'
require "sinatra/contrib"
require 'slim'
require 'sqlite3'
require "bcrypt"
require_relative "dbHandler.rb"

enable :sessions

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
  slim(:"audios/index",locals:{audioBooks:result})
end

get('/audios/new') do
  slim(:"audios/new")
end

post("/api/audios/:id/add") do 
  id = params[:id].to_i
  db = SQLite3::Database.new("db/audioBooks.db")
  db.results_as_hash = true
  result = db.execute("INSERT INTO audios (Title, authorId) VALUES (?, ?)", params[:audioBook], params[:authorId])
  redirect("/audios")
end

get("/api/audios/:id/delete") do 
  id = params[:id].to_i
  db = SQLite3::Database.new("db/audioBooks.db")
  db.results_as_hash = true
  result = db.execute("DELETE FROM audios WHERE audioId = ?", id).first
  redirect("/audios")
end

get("/audios/:id/update") do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/audioBooks.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM audios WHERE audioId = ?",id).first
  slim(:"audios/update", locals:{result:result})
end

post("/api/audios/:id/update") do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/audioBooks.db")
  db.results_as_hash = true
  result = db.execute("UPDATE audios SET Title = ?, AuthorId = ? WHERE id = ?", params[:audioBook], params[:authorId], id)
  redirect("/audios")
end

get('/audios/:id') do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/audioBooks.db")
  db.results_as_hash = true
  audio = db.execute("SELECT * FROM audios WHERE audioId = ?",id).first
  author = db.execute("SELECT * FROM authors WHERE authorId = ?", audio["authorId"]).first
  reviews = db.execute("SELECT * FROM reviews WHERE audioId = ?", id)
  slim(:"audios/show",locals:{audio:audio, author:author, reviews:reviews})
end

post("/audios/:id") do
  newReview(params[:review], session["id"], params[:id], session["username"])
  redirect("/audios/#{params[:id]}")
end


get("/signIn") do
  slim(:"signIn", locals:{})
end

post("/signIn") do
  username = params[:username]
  password = params[:password]
  signIn(username,password)
end

get('/signOut') do
  session.destroy
  redirect('/')
end

get("/signUp") do
  slim(:"signUp", locals:{})
end

post("/signUp") do
  username = params[:username]
  email = params[:email]
  password = params[:password]
  password_confirm = params[:password_confirm]
  session[:regattempt]=0
  signUp(username,email,password,password_confirm)
  signIn(username,password)
  redirect('/')
end

get("/account") do
  db = SQLite3::Database.new("db/audioBooks.db")
  db.results_as_hash = true
  user = db.execute("SELECT * FROM users WHERE id = ?",session[:id]).first
  reviews = db.execute("SELECT * FROM reviews WHERE userId = ?",session[:id])
  slim(:"account", locals:{user:user, reviews:reviews})
end