# Class to store files and directories hash just to improve performance

class Directory
  attr_accessor :name, :files, :directories

  def initialize(name)
    @name = name
    @directories = {}
    @files = {}
  end

  def add_directory(name, directory)
    if directories[name].nil?
      directories[name] = directory
    end
    return directories[name]
  end

  def add_file(name, size)
    if files[name].nil?
      files[name] = size
    end
  end

  def files_size
    files.values.sum()
  end

  def total_size
    directories_size + files_size
  end

  def directories_size
    directories.values.sum(&:total_size)
  end

  def directories_with_at_most_size(size)
    directories.values.filter { |dir| dir.total_size <= size }
    .map { |dir| dir.directories_with_at_most_size(size) << dir.name }.flatten
  end

  def total_size_of_directories_with_at_most_size(size)
    directories.values.filter { |dir| dir.total_size <= size }
    .map { |dir| (dir.total_size_of_directories_with_at_most_size(size) << dir.total_size).sum() }
  end
end


MOVE_TO_ROOT_DIRECTORY = "/"
MOVE_TO_ONE_DIRECTORY_UP = ".."
CHANGE_DIRECTORY = "cd"
COMMAND = "$"
DIR = "dir"


# Start from root directory
root =  Directory.new("root")

# Use array as stack to push/pop directories based on cd command
directories = []

# Store current directory
current_directory = root


File.open("input.txt", "r").each_line do |line|
  words = line.split(" ")
  if words[0] === COMMAND
    operation = words[1]
    argument = words[2]

    if operation === CHANGE_DIRECTORY
      if argument === MOVE_TO_ONE_DIRECTORY_UP
        directories.pop()
        current_directory = directories.last

      elsif argument == MOVE_TO_ROOT_DIRECTORY
        current_directory = root
        directories = [current_directory]
      else
        current_directory = current_directory.add_directory(argument, Directory.new(argument))
        directories.push(current_directory)
      end
    end
  else
    if words[0] != DIR
      file_name = words[1]
      file_size = words[0].to_i
      current_directory.add_file(file_name, file_size)
    end
  end

end

at_most_size = 100000

puts "total size #{root.total_size}"

puts "directories with at most size of #{at_most_size} is #{root.directories_with_at_most_size(at_most_size)}"

puts "total size of directories with at most size of #{at_most_size} is #{root.total_size_of_directories_with_at_most_size(at_most_size).sum()}"