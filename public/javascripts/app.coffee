RECORD = "Record Videos"
RSTOP = "Stop Recording"
DOWNLOAD = "Process Video"
PROCESS = "Video Processing..."
READY = "Download"

key = $('#info').attr('key')
sessionId = $('#info').attr('session')
token = $('#info').attr('token')

TB.setLogLevel(TB.DEBUG)

$('#startRecording').text(RECORD)

archiveCreatedHandler = (event) ->
  window.archive = event.archives[0]
  session.startRecording(window.archive)
  console.log window.archive

$('#loadArchiveButton').click ->
  session.loadArchive('4f78d4e3-edb6-4d21-92da-dba0f4947202')


parseArchiveResponse = (response) ->
  console.log response
  if response.status == "fail"
    setTimeout(getDownloadUrl(window.archive.archiveId), 5000)
  else
    $('#startRecording').text(READY)
    $('#startRecording').attr('href', response.url)

getDownloadUrl = ->
  $.post "/archive/#{window.archive.archiveId}", {}, parseArchiveResponse

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
      $(@).text(DOWNLOAD)
    when DOWNLOAD
      $(@).text(PROCESS)
      console.log window.archive
      setTimeout(getDownloadUrl(window.archive.archiveId), 5000)

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
sessionConnectedHandler = (event) ->
  console.log event.archives
  if event.archives[0]
    window.archive=event.archives[0]
  session.publish( publisher )
  subscribeStreams(event.streams)
streamCreatedHandler = (event) ->
  subscribeStreams(event.streams)

window.archive = ""
publisher = TB.initPublisher( key, 'myPublisherDiv' )
session = TB.initSession(sessionId)
session.addEventListener( 'sessionConnected', sessionConnectedHandler )
session.addEventListener( 'streamCreated', streamCreatedHandler )
session.addEventListener( 'archiveCreated', archiveCreatedHandler )
session.addEventListener( 'archiveLoaded', archiveLoadedHandler )
session.connect( key, token )

