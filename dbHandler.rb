configure :production, :development do
    register Sinatra::Reloader
    set :port, 3000
  end

def connect_to_db()
    db = SQLite3::Database.new("db/audioBooks.db")
end

def login(username,password)
    db = connect_to_db()
    db.results_as_hash = true
    session[:loginattempt]=0 if Time.new.to_i - session[:last_attempt].to_i > 300
    if session[:loginattempt] > 4
        session[:signinerror] = 'För många misslyckade försök. Var vänlig och försök igen senare'
        return redirect('/signIn')
    end
    result = db.execute("SELECT * FROM users WHERE name = ?",username).first
    p result
    p "wew"
    if result==nil 
        session[:loginattempt] +=1
        session[:last_attempt] = Time.now
        return redirect('/signIn')
    end  
    dbPassword = result["password"]
    id = result["id"]
    
    p BCrypt::Password.new(dbPassword) == password
    if BCrypt::Password.new(dbPassword) == password
        session[:id]= id
        session[:username] = username
        session[:email] = result["email"]
        session[:loginattempt] = nil
        session[:signinerror] = ""
        return redirect('/')
    else
        session[:loginattempt] +=1
        session[:last_attempt] = Time.now
        return redirect('/signIn')
    end
end