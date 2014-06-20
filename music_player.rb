
puts "Time to play some tunes!"

INITIAL_SONGLIST = [
  {artist: "Maserati", title: "Inventions", length: 1},
  {artist: "Hugo Kant", title: "Who's to Blame", length: 5},
  {artist: "Justice", title: "Genesis", length: 6},
  {artist: "Mord Fustang", title: "Lick The Rainbow", length: 7},
  {artist: "Mr Scruff", title: "Fish", length: 4},
  {artist: "Black Violin", title: "Brandenburg", length: 3},
  {artist: "C2C", title: "The Cell", length: 5},
  {artist: "The Chemical Brothers", title: "Snow", length: 5}
]

class MusicPlayer

  def initialize(songs)
    @songs = songs
    @current_song_index = 0
    @elapsed_song_time = 0
    @last_start_time = nil
  end

  public
  def addSong(song)
    @songs << song
    puts "Added song: #{song}"
  end

  def addSongs(songs)
    @songs.concat songs
    puts "Added songs: #{songs}"
  end

  def viewSongs
    # Make it look nice
    puts "Here is the current song list:"
    for song in @songs
      puts getSongInfo(song)
    end
  end

  def play(fromUserInput = true)
    puts "<<PLAY>>" if fromUserInput
    if isPlaying
      puts "Already playing, silly!" if fromUserInput
    else
      @playing_thread = Thread.new do
        while @current_song_index < @songs.length do
          @last_start_time = Time.now
          puts "Playing song #{getSongInfo(getCurrentSong)}"
          puts "Time remaining: #{getTimeRemainingInCurrentSong}"
          sleep(getTimeRemainingInCurrentSong)
          goToNextSong
        end
      end
    end
  end

  def pause(fromUserInput = true)
    puts "<<PAUSE>>" if fromUserInput
    if isPlaying
      @elapsed_song_time = getElapsedSongTime
      puts "Pausing Boomboox with #{getTimeRemainingInCurrentSong} left in the song: #{getSongInfo(getCurrentSong)}." if fromUserInput
      @playing_thread.kill
    else
      # Don't do anything if we're actually stopped. Otherwise, unpause.
      play(false) unless @elapsed_song_time == 0
    end
  end

  def stop(fromUserInput = true)
    puts "<<STOP>>" if fromUserInput
    if isPlaying
      @elapsed_song_time = 0
      puts "Stopping on song: #{getSongInfo(getCurrentSong)}" if fromUserInput
      @playing_thread.kill
    else
      puts "Boombox is already stopped." if fromUserInput
    end
  end

  def nextSong
    puts "<<NEXT>>"
    # puts 'in next, isPlaying', isPlaying
    wasPlaying = isPlaying
    stop(false)
    sleep 0.1
    if @current_song_index+1 < @songs.length
      puts "Skipping to next song: #{getSongInfo(@songs[@current_song_index+1])}"
    end
    goToNextSong
    play(false) if wasPlaying
  end

  def previousSong
    puts "<<PREV>>"
    # Rewind to beginning of this song
    if getElapsedSongTime > 0
      puts "Rewinding song: #{getSongInfo(getCurrentSong)}"
    else # Skip to the previous song
      if @current_song_index > 0
        @current_song_index -= 1
        puts "Skipping to previous song: #{getSongInfo(@songs[@current_song_index-1])}"
      else
        puts "Already at the beginning of the first song: #{getSongInfo(getCurrentSong)}"
      end
    end
    wasPlaying = isPlaying
    stop(false)
    sleep 0.1
    play(false) if wasPlaying
  end

  def requestMode
    puts "Welcome to the Boombox! Please enter 'shuffle' or 'ordered' to choose the play mode."
    mode = gets.chomp
    if mode == 'shuffle' or mode == 'ordered'
      shuffleSongs if mode == 'shuffle'
      puts "Thanks!"
    else
      puts "You entered something other than 'shuffle' or 'ordered'. Let's try again."
      requestMode
    end
  end

  def shuffleSongs
    puts '<<SHUFFLING>>'
    prng = Random.new
    for song in @songs
      song[:order] = prng.rand
    end
    @songs.sort_by! { |song| song[:order] }
  end

  def reset
    puts "\n<<RESET>>\n\n"
    sleep 0.1
    @elapsed_song_time = 0
    @playing_thread.kill if isPlaying
    @current_song_index = 0
    sleep 0.1
  end

  private
  def getSongInfo(song)
    "#{song[:artist]} - #{song[:title]}, length: #{song[:length]}"
  end

  def getCurrentSong
    @songs[@current_song_index]
  end

  def getTimeRemainingInCurrentSong
    (getCurrentSong[:length] - @elapsed_song_time).round(2)
  end

  def goToNextSong
    # Reset the elapsed time and go to the next song.
    @current_song_index += 1
    @elapsed_song_time = 0
    unless @current_song_index < @songs.length
      puts "You've reached the end of the playlist! Well done. Jolly good."
      stop(false)
    end
  end

  def isPlaying
    @playing_thread != nil and @playing_thread.alive?
  end

  def getElapsedSongTime
    if @last_start_time != nil and @elapsed_song_time != nil
      (Time.now - @last_start_time + @elapsed_song_time).round(2)
    else
      0
    end
  end

end


player = MusicPlayer.new(INITIAL_SONGLIST)

player.requestMode

puts "Beginning pre-determined tests. Strap in and enjoy the ride."

player.viewSongs

player.addSong({artist: "RJD2", title: "Ghostwriter", length: 4})

player.addSongs([{artist: "Poldoore", title: "Providence", length: 3}, {artist: "Massive Attack", title: "Safe From Harm", length: 5}])

player.viewSongs

# Play/play/play
puts 'TESTING: Play/play/play'
player.play
sleep 0.1
player.play
sleep 0.1
player.play

player.reset

# Play/pause/play/pause
puts 'TESTING: Play/pause/play/pause'
player.play
sleep 3.5
player.pause
sleep 0.1
player.play
sleep 2
player.pause
sleep 0.1

player.reset

# Play/pause/pause/pause/pause
puts 'TESTING: Play/pause/pause/pause/pause'
player.play
sleep 2.5
player.pause
sleep 0.1
player.pause
sleep 0.1
player.pause
sleep 0.1
player.pause
sleep 0.1

player.reset

# Play/stop/play/stop/pause
puts 'TESTING: Play/stop/play/stop/pause'
player.play
sleep 1
player.stop
sleep 0.1
player.play
sleep 2.5
player.stop
sleep 0.1
player.pause
sleep 1

player.reset

# Play/next
puts 'TESTING: Play/next'
player.play
sleep 2
player.nextSong
sleep 8

player.reset

# Play/pause/next/pause/play/nextx8
puts 'TESTING: Play/pause/next/pause/play/nextx8'
player.play
sleep 0.5
player.pause
sleep 0.1
player.nextSong
sleep 0.5
player.pause
sleep 0.1
player.play
sleep 1
player.nextSong
sleep 0.1
player.nextSong
sleep 0.1
player.nextSong
sleep 0.1
player.nextSong
sleep 0.1
player.nextSong
sleep 0.1
player.nextSong
sleep 0.1
player.nextSong
sleep 0.1
player.nextSong
sleep 0.1

player.reset

# Next/next/stop/next/play
puts 'TESTING: Next/next/stop/next/play'
player.nextSong
sleep 0.1
player.nextSong
sleep 0.1
player.stop
sleep 0.1
player.nextSong
sleep 0.1
player.play
sleep 1

player.reset

# Play/prev
puts 'TESTING: Play/prev'
player.play
sleep 3
player.previousSong
sleep 1

player.reset

# Prev/prev/play/next/next/prev
puts 'TESTING: Prev/prev/play/next/next/prev'
player.previousSong
sleep 0.1
player.previousSong
sleep 0.1
player.play
sleep 2
player.nextSong
sleep 0.1
player.nextSong
sleep 0.1
player.previousSong
sleep 2

player.reset

# Play/next/prev/stop/prev/play
puts 'TESTING: Play/next/prev/stop/prev/play'
player.play
sleep 2
player.nextSong
sleep 2
player.previousSong
sleep 0.1
player.stop
sleep 0.1
player.previousSong
sleep 0.1
player.play
sleep 0.1

player.reset
