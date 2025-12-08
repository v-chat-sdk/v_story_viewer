- video duration not synced with the story duration once you get the video duration after init the controller of it you should update the progress timer with it 
- video ui/ux not fit the content improve it since the video show very big and fill out the full screen 
- voice player not init and not play  this is the err AudioPlayers Exception: AudioPlayerException(
  UrlSource(url: https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3, mimeType: null),
  PlatformException(WebAudioError, Failed to set source. For troubleshooting, see https://github.com/bluefireteam/audioplayers/blob/main/troubleshooting.md, MediaError: MEDIA_ELEMENT_ERROR: Format error (Code: 4), null)
  RethrownDartError: PlatformException(WebAudioError, Failed to set source. For troubleshooting, see https://github.com/bluefireteam/audioplayers/blob/main/troubleshooting.md, MediaError: MEDIA_ELEMENT_ERROR: Format error (Code: 4), null)


- next story of next user group not play automatically 
- in web version the space button of the keyboard should pause the story 
- in web version we should have to arrow one in left one in right which will follow the state of the story
to move previews if their and next if there this two arrow should have green color which no next or previews in case there is not and the icon will have white color if their this is ui/ux improvements 
- for the story segment it need more improvements first no gradient color it only green color for not seen and gray color for see segments  
- in the web version we will have in the header icon for play and pause the story this will work as the space key in the keyboard and for video stories we will have option to mute and unmute the video sound 


- the sync for ui of the play and pause button not synced in case i click on it other it synced well fix this 
- i need you to improve the ui/ux of the overall of the story for the web wide screens the progress bare need to be more stroke some wide more and
- you must set make screen size for the story header with the progress bar current it take the full width of the screen which not good ui so investigate more to improve the ui/ux of it 
- and set max width for the reply also it should more bigger than the header 


- add config  option for texts not translated to be accepted by outside user  
- add emojies keybaord for the reply and configer it very well  use  emoji_picker_flutter: ^4.4.0
- add listenr for app life cycle when app not in front you should do pause for the story and when back it should resume do your best 