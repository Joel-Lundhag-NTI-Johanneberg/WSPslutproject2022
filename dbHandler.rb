def connect_to_db()
    db = SQLite3::Database.new("db/audioBooks.db")
end

# Quick and dirty way of signing in a user whilst also having some kind of rudementary warning system
def signIn(username,password)
    db = connect_to_db()
    db.results_as_hash = true

    # Stops people from trying to log in too much and too often
    session[:loginattempt]=0 if Time.new.to_i - session[:last_attempt].to_i > 300
    if session[:loginattempt] > 4
        session[:signinerror] = 'För många misslyckade försök. Var vänlig och försök igen senare'
        return redirect('/signIn')
    end

    # Get the users from database
    result = db.execute("SELECT * FROM users WHERE name = ?",username).first
    if result==nil 
        session[:loginattempt] +=1
        session[:last_attempt] = Time.now
        return redirect('/signIn')
    end  
    dbPassword = result["password"]
    id = result["id"]
    
    # Checking if the entered password could be the same as the hashed password on the database
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

# quick and dirty way of signing up with a rudementary security feature where we make sure the passwords are the same
def signUp(username,email,password,password_confirm)    
        if (password == password_confirm)
            dbPassword = BCrypt::Password.create(password)
            db = connect_to_db()
            db.execute("INSERT INTO users (name, password, listend, liked, email, role_id) VALUES (?, ?, ?, ?, ?, ?)",username, dbPassword, "[]", "[]",email, 0)
        end
end

# Function used to easily enter a new review
def newReview(review, userId, audioId, username)
    db = connect_to_db()
    db.execute("INSERT INTO reviews (review, userId, audioId, reviewer) VALUES (?, ?, ?, ?)", review, userId, audioId, username)
end