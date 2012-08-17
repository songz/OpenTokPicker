key = $('#info').attr('key')
sessionId = $('#info').attr('session')
token = $('#info').attr('token')
idle = true

TB.setLogLevel(TB.DEBUG)

archiveCreatedHandler = (event) ->
  window.archive = event.archives[0]
  session.startRecording(window.archive)
  console.log window.archive

$('#loadArchiveButton').click ->
  session.loadArchive('4f78d4e3-edb6-4d21-92da-dba0f4947202')

$('.recordButton').click ->
  console.log "button click"
  console.log window.archive
  if idle
    if window.archive==""
      session.createArchive( key, 'perSession', "#{Date.now()}")
    else
      session.startRecording(window.archive)
    idle = false
  else
    session.stopRecording( window.archive )
    session.closeArchive( window.archive )
    idle = true

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

