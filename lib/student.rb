require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade, :id

  def initialize(id=nil, name, grade)
    @name = name
    @grade = grade
    @id = id
  end
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def self.create_table
    DB[:conn].execute("
      CREATE TABLE students (id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT);
      ")
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students
        VALUES (?, ?, ?)
      SQL
      DB[:conn].execute(sql, nil, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def update
    sql = <<-SQL
      UPDATE students
      SET name=?, grade=?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.create(name, grade)
    new_student = Student.new(id=nil, name, grade)
    new_student.save
  end

  def self.new_from_db(row)
    Student.new(row[0], row[1], row[2])
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name == ?;"
    found = DB[:conn].execute(sql, name)
    Student.new_from_db(found[0])
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE students;")
  end

end
