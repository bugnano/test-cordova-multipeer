# Copyright 2016 Franco Bugnano
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#	http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

'use strict'

app = {}
window.app = app

if window.TextEncoder
	textEncoder = new TextEncoder('utf-8')
	textDecoder = new TextDecoder('utf-8')

	app.StringFromArrayBuffer = (buf) ->
		return textDecoder.decode(new Uint8Array(buf))

	app.ArrayBufferFromString = (str) ->
		return textEncoder.encode(str).buffer
else
	app.StringFromArrayBuffer = (buf) ->
		return String.fromCharCode.apply(null, new Uint8Array(buf))

	app.ArrayBufferFromString = (str) ->
		strLen = str.length
		buf = new ArrayBuffer(strLen)
		bufView = new Uint8Array(buf)

		for i in [0...strLen] by 1
			bufView[i] = str.charCodeAt(i)

		return buf

# Bind any events that are required on startup. Common events are:
# 'load', 'deviceready', 'offline', and 'online'.
document.addEventListener('deviceready', () ->
	domIds = [
		'localPeerId'
		'localPeerName'
		'localPeerHash'
		'btnStartAdvertising'
		'btnStopAdvertising'
		'lstKnownPeers'
		'btnGetPeers'
		'lstDiscoveredPeers'
		'btnStartBrowsing'
		'btnStopBrowsing'
		'lstLostPeers'
		'lstSelectedPeer'
		'peerId'
		'peerName'
		'peerHash'
		'btnInvitePeer'
		'invitationAccepted'
		'lstConnectedPeers'
		'btnGetConnectedPeers'
		'txCount'
		'rxCount'
		'rxDataLen'
		'rxData'
		'pingTime'
		'btnPingReliable'
		'btnPingUnreliable'
		'lstChangeState'
		'btnDisconnect'
		'btnClear'
	]

	dom = {}
	for id in domIds
		dom[id] = document.getElementById(id)

	networking.multipeer.getLocalPeerInfo((peerInfo) ->
		dom.localPeerId.innerHTML = String(peerInfo.id)
		dom.localPeerName.innerHTML = String(peerInfo.name)
		dom.localPeerHash.innerHTML = String(peerInfo.hash)
		return
	)

	app.serviceType = 'test-cdv-mpc'

	dom.btnStartAdvertising.addEventListener('click', () ->
		networking.multipeer.startAdvertising(app.serviceType, () ->
			console.log('OK: startAdvertising')
			return
		, () ->
			console.log('ERROR: startAdvertising')
			return
		)
		return
	)

	dom.btnStopAdvertising.addEventListener('click', () ->
		console.log('stopAdvertising')
		networking.multipeer.stopAdvertising()
		return
	)

	app.nextID = 0
	app.peers = {}
	app.selectedPeer = null
	app.connectedPeers = []

	app.showPeerInfo = (e) ->
		btn = e.target
		id = btn.getAttribute('id')
		peer = app.peers[id]
		app.selectedPeer = peer

		dom.peerId.innerHTML = String(peer.id)
		dom.peerName.innerHTML = String(peer.name)
		dom.peerHash.innerHTML = String(peer.hash)
		return

	dom.btnGetPeers.addEventListener('click', () ->
		console.log('getPeers')
		dom.lstKnownPeers.innerHTML = ''
		networking.multipeer.getPeers((peers) ->
			for peer in peers
				btn = document.createElement('button')
				btn.setAttribute('type', 'button')
				btn.classList.add('list-group-item')
				id = "mpcPeer#{app.nextID}"
				btn.setAttribute('id', id)
				btn.innerHTML = "#{peer.id} -- #{peer.hash}: #{peer.name}"
				dom.lstKnownPeers.appendChild(btn)
				btn.addEventListener('click', app.showPeerInfo)
				app.nextID += 1
				app.peers[id] = peer

			return
		)
		return
	)

	dom.btnStartBrowsing.addEventListener('click', () ->
		networking.multipeer.startBrowsing(app.serviceType, () ->
			console.log('OK: startBrowsing')
			return
		, () ->
			console.log('ERROR: startBrowsing')
			return
		)
		return
	)

	dom.btnStopBrowsing.addEventListener('click', () ->
		console.log('stopBrowsing')
		networking.multipeer.stopBrowsing()
		return
	)

	networking.multipeer.onFoundPeer.addListener((peerInfo) ->
		console.log('onFoundPeer')
		btn = document.createElement('button')
		btn.setAttribute('type', 'button')
		btn.classList.add('list-group-item')
		id = "mpcPeer#{app.nextID}"
		btn.setAttribute('id', id)
		btn.innerHTML = "#{peerInfo.id} -- #{peerInfo.hash}: #{peerInfo.name}"
		dom.lstDiscoveredPeers.appendChild(btn)
		btn.addEventListener('click', app.showPeerInfo)
		app.nextID += 1
		app.peers[id] = peerInfo
		return
	)

	networking.multipeer.onLostPeer.addListener((peerInfo) ->
		console.log('onLostPeer')
		btn = document.createElement('button')
		btn.setAttribute('type', 'button')
		btn.classList.add('list-group-item')
		id = "mpcPeer#{app.nextID}"
		btn.setAttribute('id', id)
		btn.innerHTML = "#{peerInfo.id} -- #{peerInfo.hash}: #{peerInfo.name}"
		dom.lstLostPeers.appendChild(btn)
		btn.addEventListener('click', app.showPeerInfo)
		app.nextID += 1
		app.peers[id] = peerInfo
		return
	)

	dom.btnInvitePeer.addEventListener('click', () ->
		peer = app.selectedPeer
		if not peer
			console.log('ERROR: btnInvitePeer -- No peer selected')
			return

		networking.multipeer.invitePeer(peer.id, () ->
			console.log('OK: invitePeer')
			return
		, () ->
			console.log('ERROR: invitePeer')
			return
		)

		return
	)

	networking.multipeer.onReceiveInvitation.addListener((invitationInfo) ->
		console.log('onReceiveInvitation')
		console.log(invitationInfo)
		peerInfo = invitationInfo.peerInfo
		networking.multipeer.acceptInvitation(invitationInfo.invitationId, () ->
			dom.invitationAccepted.innerHTML = "OK: Accept invitation from peer id: #{peerInfo.id} hash: #{peerInfo.hash} name: #{peerInfo.name}"
			return
		, () ->
			dom.invitationAccepted.innerHTML = "ERROR: Accept invitation from peer id: #{peerInfo.id} hash: #{peerInfo.hash} name: #{peerInfo.name}"
			return
		)

		return
	)

	app.tx_count = 0
	app.rx_count = 0
	app.pingReliableStr = 'Hello, reliable world\n'
	app.pingUnreliableStr = 'Hello, unreliable world\n'
	app.pongReliableStr = 'Goodbye, mostly reliable world\n'
	app.pongUnreliableStr = 'Goodbye, mostly unreliable world\n'
	app.pingReliableData = app.ArrayBufferFromString(app.pingReliableStr)
	app.pingUnreliableData = app.ArrayBufferFromString(app.pingUnreliableStr)
	app.pongReliableData = app.ArrayBufferFromString(app.pongReliableStr)
	app.pongUnreliableData = app.ArrayBufferFromString(app.pongUnreliableStr)
	app.startTime = performance.now()

	dom.btnGetConnectedPeers.addEventListener('click', () ->
		console.log('btnGetConnectedPeers')
		dom.lstConnectedPeers.innerHTML = ''
		networking.multipeer.getConnectedPeers((peers) ->
			for peer in peers
				btn = document.createElement('button')
				btn.setAttribute('type', 'button')
				btn.classList.add('list-group-item')
				btn.innerHTML = "#{peer.id} -- #{peer.hash}: #{peer.name}"
				dom.lstConnectedPeers.appendChild(btn)

			return
		)

		return
	)

	dom.btnPingReliable.addEventListener('click', () ->
		console.log('btnPingReliable')
		app.tx_count += 1
		dom.txCount.innerHTML = String(app.tx_count)

		app.startTime = performance.now()
		networking.multipeer.sendDataReliable(app.connectedPeers, app.pingReliableData, (bytes_sent) ->
			console.log("OK: sendDataReliable #{bytes_sent}")
			return
		, (errorMessage) ->
			console.log("ERROR: sendDataReliable #{errorMessage}")
			return
		)

		return
	)

	dom.btnPingUnreliable.addEventListener('click', () ->
		console.log('btnPingUnreliable')
		app.tx_count += 1
		dom.txCount.innerHTML = String(app.tx_count)

		app.startTime = performance.now()
		networking.multipeer.sendDataUnreliable(app.connectedPeers, app.pingUnreliableData, (bytes_sent) ->
			console.log("OK: sendDataUnreliable #{bytes_sent}")
			return
		, (errorMessage) ->
			console.log("ERROR: sendDataUnreliable #{errorMessage}")
			return
		)

		return
	)

	networking.multipeer.onReceiveData.addListener((receiveInfo) ->
		ping_time = performance.now() - app.startTime
		console.log('onReceiveData')

		peerId = receiveInfo.peerInfo.id
		if app.connectedPeers.indexOf(peerId) < 0
			console.log("ERROR: onReceiveData -- app.connectedPeers.indexOf(peerId) < 0 -- peerId: #{peerId}")
			return

		data = app.StringFromArrayBuffer(receiveInfo.data)

		if data == app.pingReliableStr
			networking.multipeer.sendDataReliable(peerId, app.pongReliableData)
		else if data == app.pingUnreliableStr
			networking.multipeer.sendDataUnreliable(peerId, app.pongUnreliableData)
		else
			dom.pingTime.innerHTML = String(ping_time)

		app.rx_count += 1
		dom.rxCount.innerHTML = String(app.rx_count)
		dom.rxDataLen.innerHTML = String(data.length)
		dom.rxData.innerHTML = String(data)

		return
	)

	networking.multipeer.onChangeState.addListener((stateInfo) ->
		# stateInfo is an object with the following members:
		# peerInfo --> The peer whose state is changed (a complete peerInfo object, not just its id)
		# state --> A string that can contain one of the following values:
		#  'NotConnected'
		#  'Connecting'
		#  'Connected'
		console.log('onChangeState')
		console.log(stateInfo)

		peer = stateInfo.peerInfo

		btn = document.createElement('button')
		btn.setAttribute('type', 'button')
		btn.classList.add('list-group-item')
		btn.innerHTML = "#{peer.id} -- #{peer.hash}: #{peer.name} -- #{stateInfo.state}"
		dom.lstChangeState.appendChild(btn)

		if stateInfo.state == 'Connected'
			if app.connectedPeers.indexOf(peer.id) < 0
				app.connectedPeers.push(peer.id)
		else
			index = app.connectedPeers.indexOf(peer.id) < 0
			if index >= 0
				app.connectedPeers.splice(index, 1)

		return
	)

	dom.btnDisconnect.addEventListener('click', () ->
		console.log('btnDisconnect')
		networking.multipeer.disconnect()

		return
	)

	dom.btnClear.addEventListener('click', () ->
		console.log('btnClear')

		dom.invitationAccepted.innerHTML = ''

		dom.lstKnownPeers.innerHTML = ''
		dom.lstDiscoveredPeers.innerHTML = ''
		dom.lstLostPeers.innerHTML = ''
		dom.lstConnectedPeers.innerHTML = ''
		dom.lstChangeState.innerHTML = ''

		app.selectedPeer = null
		dom.peerId.innerHTML = ''
		dom.peerName.innerHTML = ''
		dom.peerHash.innerHTML = ''

		return
	)

	console.log('Prima di testHugeBuffer')

	app.testHugeBuffer = () ->
		buf = new ArrayBuffer(4096)
		bufView = new Uint8Array(buf)

		for i in [0...bufView.length] by 1
			bufView[i] = 0x55

		if app.clientSocketId != null
			socket_id = app.clientSocketId
		else
			socket_id = app.socketId

		startTime = performance.now()
		networking.bluetooth.send(socket_id, buf, (num_byte) ->
			end_time = performance.now() - startTime
			console.log("success: #{num_byte}")
			console.log("end_time: #{end_time}")
		, (errorMessage) ->
			end_time = performance.now() - startTime
			console.log("error: #{errorMessage}")
			console.log("end_time: #{end_time}")
		)
		send_time = performance.now() - startTime

		console.log("send_time: #{send_time}")
		return
, false)

