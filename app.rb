require 'sinatra'
require "sinatra/contrib"
require 'slim'
require 'sqlite3'
require "bcrypt"
require_relative "dbHandler.rb"

enable :sessions

get('/')  do 
  slim(:start)
end 

# Get all audiobooks from database to display them in a list
get('/audios') do
  db = SQLite3::Database.new("db/audioBooks.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM audios")
  slim(:"audios/index",locals:{audioBooks:result})
end

# Create a new audiobook
get('/audios/new') do
  slim(:"audios/new")
end

# Creates audioBook and adds it to database
post("/api/audios/add") do 
  id = params[:id].to_i
  db = SQLite3::Database.new("db/audioBooks.db")
  db.results_as_hash = true
  result = db.execute("INSERT INTO audios (Title, authorId) VALUES (?, ?)", params[:audio], params[:authorId])
  redirect("/audios")
end

# Delete audiobook from database
get("/api/audios/:id/delete") do 
  id = params[:id].to_i
  db = SQLite3::Database.new("db/audioBooks.db")
  db.results_as_hash = true
  result = db.execute("DELETE FROM audios WHERE audioId = ?", id).first
  redirect("/audios")
end

# Update audiobook info
get("/audios/:id/update") do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/audioBooks.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM audios WHERE audioId = ?",id).first
  slim(:"audios/update", locals:{result:result})
end

# push the update to database
post("/api/audios/:id/update") do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/audioBooks.db")
  db.results_as_hash = true
  result = db.execute("UPDATE audios SET Title = ?, AuthorId = ? WHERE audioId = ?", params[:audio], params[:authorId], id)
  redirect("/audios")
end

# show the audiobook you clicked on from the index page
get('/audios/:id') do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/audioBooks.db")
  db.results_as_hash = true
  audio = db.execute("SELECT * FROM audios WHERE audioId = ?",id).first
  author = db.execute("SELECT * FROM authors WHERE authorId = ?", audio["authorId"]).first
  reviews = db.execute("SELECT * FROM reviews WHERE audioId = ?", id)
  slim(:"audios/show",locals:{audio:audio, author:author, reviews:reviews})
end

# add a review to database
post("/audios/:id") do
  newReview(params[:review], session["id"], params[:id], session["username"])
  redirect("/audios/#{params[:id]}")
end

# Sign in page
get("/signIn") do
  slim(:"signIn", locals:{})
end

# start sign in function
post("/signIn") do
  username = params[:username]
  password = params[:password]
  signIn(username,password)
end

# signout function
get('/signOut') do
  session.destroy
  redirect('/')
end

# create a new account page
get("/signUp") do
  slim(:"signUp", locals:{})
end

# start the create new account function and push info to database
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

# get account information and show it to user
get("/account") do
  db = SQLite3::Database.new("db/audioBooks.db")
  db.results_as_hash = true
  user = db.execute("SELECT * FROM users WHERE id = ?",session[:id]).first
  reviews = db.execute("SELECT * FROM reviews WHERE userId = ?",session[:id])
  slim(:"account", locals:{user:user, reviews:reviews})
end