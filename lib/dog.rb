class Dog

  attr_accessor :name, :breed , :id 

  def initialize(id: nil, name: , breed: )
    @name = name 
    @breed =breed
    @id = id 
  end 

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id  INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
      SQL
       DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end 

  def save 
    if self.id
      self.update
    else
      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
      DB[:conn].execute(sql, self.name, self.breed)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self 
  end 

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog 

  end 
  def self.find_by_id(ids)
    sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1"
    DB[:conn].execute(sql, ids).map do |row|
      self.new_from_db(row)
    end.first
  end


  def self.find_or_create_by(name:, breed:)
     sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
     row = DB[:conn].execute(sql, name, breed)
     if row.count > 0
       new_from_db(row[0])
     else
       create(name: name, breed: breed)
     end
   end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    self.new(id: id, name: name, breed: breed)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end 