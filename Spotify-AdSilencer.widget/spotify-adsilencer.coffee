# This is a simple example Widget, written in CoffeeScript, to get you started
# with Übersicht. For the full documentation please visit:
#
# https://github.com/felixhageloh/uebersicht
#
# You can modify this widget as you see fit, or simply delete this file to
# remove it.

# the CSS style for this widget, written using Stylus
# (http://learnboost.github.io/stylus/)

# the refresh frequency in milliseconds
refreshFrequency: 1000

style: """

  player = 1
  bottom = 10px
  right = 10%

  if player
    display-player = inherit
  else
    display-player = none

  bottom: bottom
  right: right
  background-color: rgba(255,255,255,0.1)
  font-family: "Montserrat", sans-serif
  width: 250px;
  height: 250px;
  border-radius: 400px;
  display: display-player;

  .album-img
    display: block
    margin: 0 auto
    height: 90px
    margin-top: 10%

  .track-name
    color: rgb(47,213,102)
    text-align: center
    padding-top: 10px
    margin-left: 17px
    margin-right: 17px
    /*white-space: nowrap
    overflow: hidden
    word-wrap: break-word*/

  .artist-name
    color: #fff
    text-align: center
    padding-top: 10px

  .player
    text-align: center
    & i
      padding: 15px
      font-size: 1.7em
    & i.hidden
      display: none

  /* vietnamese */

"""

# this is the shell command that gets executed every time this widget refreshes
command: "source Spotify-AdSilencer.widget/spotify-info.sh"

# render gets called after the shell command has executed. The command's output
# is passed in as a string. Whatever it returns will get rendered as HTML.
render: (output) -> """
  <img name="album-img" class="album-img">
  <div class="track-name" name="track"></div>
  <div class="artist-name" name="artist"></div>
  <div class="player" name="player">
    <i class="fa fa-backward" name="song-backward" aria-hidden="true" style="color:#000"></i>
    <i class="fa fa-play" name="song-play" aria-hidden="true" style="color:#000"></i>
    <i class="fa fa-pause hidden" name="song-pause" aria-hidden="true" style="color:#000"></i>
    <i class="fa fa-forward" name="song-forward" aria-hidden="true" style="color:#000"></i>
  </div>
  <link rel="stylesheet" href="Spotify-AdSilencer.widget/css/font-awesome.min.css">
"""

# Update the rendered output.
update: (output, domEl) ->

  adDetected = (self) ->
    $('[name="track"]').html("Ad detected")
    $('[name="artist"]').html("Ad detected")
    $('[name="album-img"]').attr('src','Spotify-AdSilencer.widget/images/ad.png')
    localStorage.setItem "spotifyAd", 1
    #localStorage.setItem "spotifyVolume", 0

  setTrackName = ( trackName ) ->
    trackName = cutStringToFill(trackName)
    
    $('[name="track"]').html(trackName)

  setArtistName = ( artistName ) ->
    artistName = cutStringToFill(artistName)

    $('[name="artist"]').html(artistName)

  setAlbumImage = ( albumUrl ) ->
    $('[name="album-img"]').attr('src',albumUrl)
    $('[name="album-img"]').attr('width','100px')
    $('[name="album-img"]').attr('height','100px')


  cutStringToFill = (string) ->
    maxLength = 27
    stringLength = string.length
    if stringLength > maxLength
      string = string.substring(0,maxLength-1) + " ..."

    return string

  playPausePlayer = (playerState) ->
    if playerState.trim() in ['paused', 'stopped']
      $('[name="song-pause"]').addClass('hidden')
      $('[name="song-play"]').removeClass('hidden')
    else if playerState.trim() in ['playing']
      $('[name="song-play"]').addClass('hidden')
      $('[name="song-pause"]').removeClass('hidden')

  trackInfoArray = output.split "|"
  if trackInfoArray
    trackName = trackInfoArray[0]
    playerState = trackInfoArray[3]
    playPausePlayer(playerState)
    if trackName
      setTrackName(trackName)
      artistName = trackInfoArray[1]
      if artistName
        setArtistName(artistName)
        albumUrl = trackInfoArray[2]
        if albumUrl
          setAlbumImage(albumUrl)
  
afterRender: (domEl)->

  playPauseSong = (self) ->
    self.run "osascript -e 'tell application \"Spotify\" to playpause'"

  forwardSong = (self) ->
    self.run "osascript -e 'tell application \"Spotify\" to next track'"
  
  backwardSong = (self)->
    self.run "osascript -e 'tell application \"Spotify\" to previous track'"

  self = this

  $(domEl).find('[name="song-play"]').on 'click', => 
    playPauseSong(self)
    $('[name="song-play"]').addClass('hidden')
    $('[name="song-pause"]').removeClass('hidden')

  $(domEl).find('[name="song-pause"]').on 'click', => 
    playPauseSong(self)
    $('[name="song-pause"]').addClass('hidden')
    $('[name="song-play"]').removeClass('hidden')

  $(domEl).find('[name="song-forward"]').on 'click', => 
    forwardSong(self)
    $('[name="song-play"]').addClass('hidden')
    $('[name="song-pause"]').removeClass('hidden')

  $(domEl).find('[name="song-backward"]').on 'click', => 
    backwardSong(self)
    $('[name="song-play"]').addClass('hidden')
    $('[name="song-pause"]').removeClass('hidden')