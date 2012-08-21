RECORD = "Record Videos"
RSTOP = "Stop Recording"
DOWNLOAD = "Process Video"
PROCESS = "Video Processing..."
READY = "Download"

interval = ""
key = $('#info').attr('key')
sessionId = $('#info').attr('session')
token = $('#info').attr('token')
downloadURL=""
users = 0

TB.setLogLevel(TB.DEBUG)

filepicker.setKey( $('#info').attr('FPKey') )

parseArchiveResponse = (response) ->
  console.log response
  if response.status != "fail"
    window.clearInterval(interval)
    $('#startRecording').text(READY)
    downloadURL = 'http://'+response.url.split('https://')[1]
    $('#processingMessage').fadeOut()

getDownloadUrl = ->
  $.post "/archive/#{window.archive.archiveId}", {token:$('#info').attr('token')}, parseArchiveResponse

setRecordingCapability = ->
    $('#startRecording').text(RECORD)
    $('#startRecording').addClass('recordButton')
    $('#startRecording').removeClass('initialButton')
    $('#startRecording').click ->
      console.log "button click"
      console.log window.archive
      switch $(@).text()
        when RECORD
          if window.archive==""
            session.createArchive( key, 'perSession', "#{Date.now()}")
          else
            session.startRecording(window.archive)
          $(@).text(RSTOP)
        when RSTOP
          session.stopRecording( window.archive )
          session.closeArchive( window.archive )
          $(@).text(PROCESS)
          $('#processingMessage').fadeIn()
        when READY
          $('#endMessage').fadeIn()
          filepicker.saveAs downloadURL,'', (url) ->
            $('#endMessage').fadeIn()

archiveClosedHandler = (event) ->
  console.log window.archive
  interval = window.setInterval(getDownloadUrl, 5000)

archiveCreatedHandler = (event) ->
  window.archive = event.archives[0]
  session.startRecording(window.archive)
  console.log window.archive

archiveLoadedHandler = (event) ->
  window.archive = event.archives[0]
  window.archive.startPlayback()

subscribeStreams = (streams) ->
  for stream in streams
    if stream.connection.connectionId == session.connection.connectionId
      return
    divId = "stream#{stream.streamId}"
    div = $('<div />', {id:divId})
    $('#pubContainer').append(div)
    session.subscribe(stream, divId)
    users += 1
sessionConnectedHandler = (event) ->
  console.log event.archives
  if event.archives[0]
    window.archive=event.archives[0]
  subscribeStreams(event.streams)
  session.publish( publisher )
  users = event.streams.length
  if users==0
    setRecordingCapability()
streamCreatedHandler = (event) ->
  subscribeStreams(event.streams)
streamDestroyedHandler = (event) ->
  users -= 1
  if users==0 # including myself
    setRecordingCapability()

window.archive = ""
publisher = TB.initPublisher( key, 'myPublisherDiv' )
session = TB.initSession(sessionId)
session.addEventListener( 'sessionConnected', sessionConnectedHandler )
session.addEventListener( 'streamCreated', streamCreatedHandler )
session.addEventListener( 'streamDestroyed', streamDestroyedHandler )
session.addEventListener( 'archiveCreated', archiveCreatedHandler )
session.addEventListener( 'archiveClosed', archiveClosedHandler )
session.addEventListener( 'archiveLoaded', archiveLoadedHandler )
session.connect( key, token )

$('#refresh').click ->
  window.location = window.location
