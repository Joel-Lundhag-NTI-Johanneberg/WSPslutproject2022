configure :production, :development do
    register Sinatra::Reloader
    set :port, 3000
  end

def connect_to_db()
    db = SQLite3::Database.new("db/audioBooks.db")
end

def signIn(username,password)
    db = connect_to_db()
    db.results_as_hash = true
    session[:loginattempt]=0 if Time.new.to_i - session[:last_attempt].to_i > 300
    if session[:loginattempt] > 4
        session[:signinerror] = 'För många misslyckade försök. Var vänlig och försök igen senare'
        return redirect('/signIn')
    end
    result = db.execute("SELECT * FROM users WHERE name = ?",username).first
    if result==nil 
        session[:loginattempt] +=1
        session[:last_attempt] = Time.now
        return redirect('/signIn')
    end  
    dbPassword = result["password"]
    id = result["id"]
    
    if BCrypt::Password.new(dbPassword) == password
        session[:id]= id
        session[:username] = username
        session[:email] = result["email"]
        session[:role_id] = result["role_id"]
        session[:loginattempt] = nil
        session[:signinerror] = ""
        return redirect('/')
    else
        session[:loginattempt] +=1
        session[:last_attempt] = Time.now
        return redirect('/signIn')
    end
end

def signUp(username,email,password,password_confirm)    
        regattempt=0
            if (password == password_confirm)
        dbPassword = BCrypt::Password.create(password)
        db = connect_to_db()
        db.execute("INSERT INTO users (name, password, reviews, listend, liked, email, role_id) VALUES (?, ?, ?, ?, ?, ?, ?)",username, dbPassword, "[]", "[]", "[]",email, 0)
        regattempt = nil
        return regattempt
        else
        regattempt +=1
        return regattempt
        end
    end

def newReview(review, userId, audioId, username)
    db = connect_to_db()
    db.execute("INSERT INTO reviews (review, userId, audioId, reviewer) VALUES (?, ?, ?, ?)", review, userId, audioId, username)
end