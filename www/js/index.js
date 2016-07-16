// Generated by CoffeeScript 1.10.0
(function() {
  'use strict';
  var app, textDecoder, textEncoder;

  app = {};

  window.app = app;

  if (window.TextEncoder) {
    textEncoder = new TextEncoder('utf-8');
    textDecoder = new TextDecoder('utf-8');
    app.StringFromArrayBuffer = function(buf) {
      return textDecoder.decode(new Uint8Array(buf));
    };
    app.ArrayBufferFromString = function(str) {
      return textEncoder.encode(str).buffer;
    };
  } else {
    app.StringFromArrayBuffer = function(buf) {
      return String.fromCharCode.apply(null, new Uint8Array(buf));
    };
    app.ArrayBufferFromString = function(str) {
      var buf, bufView, i, j, ref, strLen;
      strLen = str.length;
      buf = new ArrayBuffer(strLen);
      bufView = new Uint8Array(buf);
      for (i = j = 0, ref = strLen; j < ref; i = j += 1) {
        bufView[i] = str.charCodeAt(i);
      }
      return buf;
    };
  }

  document.addEventListener('deviceready', function() {
    var dom, domIds, id, j, len;
    domIds = ['localPeerId', 'localPeerName', 'localPeerHash', 'btnStartAdvertising', 'btnStopAdvertising', 'lstKnownPeers', 'btnGetPeers', 'lstDiscoveredPeers', 'btnStartBrowsing', 'btnStopBrowsing', 'lstLostPeers', 'lstSelectedPeer', 'peerId', 'peerName', 'peerHash', 'btnInvitePeer', 'invitationAccepted', 'lstConnectedPeers', 'btnGetConnectedPeers', 'txCount', 'rxCount', 'rxDataLen', 'rxData', 'pingTime', 'btnPingReliable', 'btnPingUnreliable', 'lstChangeState', 'btnDisconnect', 'btnClear'];
    dom = {};
    for (j = 0, len = domIds.length; j < len; j++) {
      id = domIds[j];
      dom[id] = document.getElementById(id);
    }
    networking.multipeer.getLocalPeerInfo(function(peerInfo) {
      dom.localPeerId.innerHTML = String(peerInfo.id);
      dom.localPeerName.innerHTML = String(peerInfo.name);
      dom.localPeerHash.innerHTML = String(peerInfo.hash);
    });
    app.serviceType = 'test-cdv-mpc';
    dom.btnStartAdvertising.addEventListener('click', function() {
      networking.multipeer.startAdvertising(app.serviceType, function() {
        console.log('OK: startAdvertising');
      }, function() {
        console.log('ERROR: startAdvertising');
      });
    });
    dom.btnStopAdvertising.addEventListener('click', function() {
      console.log('stopAdvertising');
      networking.multipeer.stopAdvertising();
    });
    app.nextID = 0;
    app.peers = {};
    app.selectedPeer = null;
    app.connectedPeers = [];
    app.showPeerInfo = function(e) {
      var btn, peer;
      btn = e.target;
      id = btn.getAttribute('id');
      peer = app.peers[id];
      app.selectedPeer = peer;
      dom.peerId.innerHTML = String(peer.id);
      dom.peerName.innerHTML = String(peer.name);
      dom.peerHash.innerHTML = String(peer.hash);
    };
    dom.btnGetPeers.addEventListener('click', function() {
      console.log('getPeers');
      dom.lstKnownPeers.innerHTML = '';
      networking.multipeer.getPeers(function(peers) {
        var btn, k, len1, peer;
        for (k = 0, len1 = peers.length; k < len1; k++) {
          peer = peers[k];
          btn = document.createElement('button');
          btn.setAttribute('type', 'button');
          btn.classList.add('list-group-item');
          id = "mpcPeer" + app.nextID;
          btn.setAttribute('id', id);
          btn.innerHTML = peer.id + " -- " + peer.hash + ": " + peer.name;
          dom.lstKnownPeers.appendChild(btn);
          btn.addEventListener('click', app.showPeerInfo);
          app.nextID += 1;
          app.peers[id] = peer;
        }
      });
    });
    dom.btnStartBrowsing.addEventListener('click', function() {
      networking.multipeer.startBrowsing(app.serviceType, function() {
        console.log('OK: startBrowsing');
      }, function() {
        console.log('ERROR: startBrowsing');
      });
    });
    dom.btnStopBrowsing.addEventListener('click', function() {
      console.log('stopBrowsing');
      networking.multipeer.stopBrowsing();
    });
    networking.multipeer.onFoundPeer.addListener(function(peerInfo) {
      var btn;
      console.log('onFoundPeer');
      btn = document.createElement('button');
      btn.setAttribute('type', 'button');
      btn.classList.add('list-group-item');
      id = "mpcPeer" + app.nextID;
      btn.setAttribute('id', id);
      btn.innerHTML = peerInfo.id + " -- " + peerInfo.hash + ": " + peerInfo.name;
      dom.lstDiscoveredPeers.appendChild(btn);
      btn.addEventListener('click', app.showPeerInfo);
      app.nextID += 1;
      app.peers[id] = peerInfo;
    });
    networking.multipeer.onLostPeer.addListener(function(peerInfo) {
      var btn;
      console.log('onLostPeer');
      btn = document.createElement('button');
      btn.setAttribute('type', 'button');
      btn.classList.add('list-group-item');
      id = "mpcPeer" + app.nextID;
      btn.setAttribute('id', id);
      btn.innerHTML = peerInfo.id + " -- " + peerInfo.hash + ": " + peerInfo.name;
      dom.lstLostPeers.appendChild(btn);
      btn.addEventListener('click', app.showPeerInfo);
      app.nextID += 1;
      app.peers[id] = peerInfo;
    });
    dom.btnInvitePeer.addEventListener('click', function() {
      var peer;
      peer = app.selectedPeer;
      if (!peer) {
        console.log('ERROR: btnInvitePeer -- No peer selected');
        return;
      }
      networking.multipeer.invitePeer(peer.id, function() {
        console.log('OK: invitePeer');
      }, function() {
        console.log('ERROR: invitePeer');
      });
    });
    networking.multipeer.onReceiveInvitation.addListener(function(invitationInfo) {
      var peerInfo;
      console.log('onReceiveInvitation');
      console.log(invitationInfo);
      peerInfo = invitationInfo.peerInfo;
      networking.multipeer.acceptInvitation(invitationInfo.invitationId, function() {
        dom.invitationAccepted.innerHTML = "OK: Accept invitation from peer id: " + peerInfo.id + " hash: " + peerInfo.hash + " name: " + peerInfo.name;
      }, function() {
        dom.invitationAccepted.innerHTML = "ERROR: Accept invitation from peer id: " + peerInfo.id + " hash: " + peerInfo.hash + " name: " + peerInfo.name;
      });
    });
    app.tx_count = 0;
    app.rx_count = 0;
    app.pingReliableStr = 'Hello, reliable world\n';
    app.pingUnreliableStr = 'Hello, unreliable world\n';
    app.pongReliableStr = 'Goodbye, mostly reliable world\n';
    app.pongUnreliableStr = 'Goodbye, mostly unreliable world\n';
    app.pingReliableData = app.ArrayBufferFromString(app.pingReliableStr);
    app.pingUnreliableData = app.ArrayBufferFromString(app.pingUnreliableStr);
    app.pongReliableData = app.ArrayBufferFromString(app.pongReliableStr);
    app.pongUnreliableData = app.ArrayBufferFromString(app.pongUnreliableStr);
    app.startTime = performance.now();
    dom.btnGetConnectedPeers.addEventListener('click', function() {
      console.log('btnGetConnectedPeers');
      dom.lstConnectedPeers.innerHTML = '';
      networking.multipeer.getConnectedPeers(function(peers) {
        var btn, k, len1, peer;
        for (k = 0, len1 = peers.length; k < len1; k++) {
          peer = peers[k];
          btn = document.createElement('button');
          btn.setAttribute('type', 'button');
          btn.classList.add('list-group-item');
          btn.innerHTML = peer.id + " -- " + peer.hash + ": " + peer.name;
          dom.lstConnectedPeers.appendChild(btn);
        }
      });
    });
    dom.btnPingReliable.addEventListener('click', function() {
      console.log('btnPingReliable');
      app.tx_count += 1;
      dom.txCount.innerHTML = String(app.tx_count);
      app.startTime = performance.now();
      networking.multipeer.sendDataReliable(app.connectedPeers, app.pingReliableData, function(bytes_sent) {
        console.log("OK: sendDataReliable " + bytes_sent);
      }, function(errorMessage) {
        console.log("ERROR: sendDataReliable " + errorMessage);
      });
    });
    dom.btnPingUnreliable.addEventListener('click', function() {
      console.log('btnPingUnreliable');
      app.tx_count += 1;
      dom.txCount.innerHTML = String(app.tx_count);
      app.startTime = performance.now();
      networking.multipeer.sendDataUnreliable(app.connectedPeers, app.pingUnreliableData, function(bytes_sent) {
        console.log("OK: sendDataUnreliable " + bytes_sent);
      }, function(errorMessage) {
        console.log("ERROR: sendDataUnreliable " + errorMessage);
      });
    });
    networking.multipeer.onReceiveData.addListener(function(receiveInfo) {
      var data, peerId, ping_time;
      ping_time = performance.now() - app.startTime;
      console.log('onReceiveData');
      peerId = receiveInfo.peerInfo.id;
      if (app.connectedPeers.indexOf(peerId) < 0) {
        console.log("ERROR: onReceiveData -- app.connectedPeers.indexOf(peerId) < 0 -- peerId: " + peerId);
        return;
      }
      data = app.StringFromArrayBuffer(receiveInfo.data);
      if (data === app.pingReliableStr) {
        networking.multipeer.sendDataReliable(peerId, app.pongReliableData);
      } else if (data === app.pingUnreliableStr) {
        networking.multipeer.sendDataUnreliable(peerId, app.pongUnreliableData);
      } else {
        dom.pingTime.innerHTML = String(ping_time);
      }
      app.rx_count += 1;
      dom.rxCount.innerHTML = String(app.rx_count);
      dom.rxDataLen.innerHTML = String(data.length);
      dom.rxData.innerHTML = String(data);
    });
    networking.multipeer.onChangeState.addListener(function(stateInfo) {
      var btn, index, peer;
      console.log('onChangeState');
      console.log(stateInfo);
      peer = stateInfo.peerInfo;
      btn = document.createElement('button');
      btn.setAttribute('type', 'button');
      btn.classList.add('list-group-item');
      btn.innerHTML = peer.id + " -- " + peer.hash + ": " + peer.name + " -- " + stateInfo.state;
      dom.lstChangeState.appendChild(btn);
      if (stateInfo.state === 'Connected') {
        if (app.connectedPeers.indexOf(peer.id) < 0) {
          app.connectedPeers.push(peer.id);
        }
      } else {
        index = app.connectedPeers.indexOf(peer.id) < 0;
        if (index >= 0) {
          app.connectedPeers.splice(index, 1);
        }
      }
    });
    dom.btnDisconnect.addEventListener('click', function() {
      console.log('btnDisconnect');
      networking.multipeer.disconnect();
    });
    dom.btnClear.addEventListener('click', function() {
      console.log('btnClear');
      dom.invitationAccepted.innerHTML = '';
      dom.lstKnownPeers.innerHTML = '';
      dom.lstDiscoveredPeers.innerHTML = '';
      dom.lstLostPeers.innerHTML = '';
      dom.lstConnectedPeers.innerHTML = '';
      dom.lstChangeState.innerHTML = '';
      app.selectedPeer = null;
      dom.peerId.innerHTML = '';
      dom.peerName.innerHTML = '';
      dom.peerHash.innerHTML = '';
    });
    console.log('Prima di testHugeBuffer');
    return app.testHugeBuffer = function() {
      var buf, bufView, i, k, ref, send_time, socket_id, startTime;
      buf = new ArrayBuffer(4096);
      bufView = new Uint8Array(buf);
      for (i = k = 0, ref = bufView.length; k < ref; i = k += 1) {
        bufView[i] = 0x55;
      }
      if (app.clientSocketId !== null) {
        socket_id = app.clientSocketId;
      } else {
        socket_id = app.socketId;
      }
      startTime = performance.now();
      networking.bluetooth.send(socket_id, buf, function(num_byte) {
        var end_time;
        end_time = performance.now() - startTime;
        console.log("success: " + num_byte);
        return console.log("end_time: " + end_time);
      }, function(errorMessage) {
        var end_time;
        end_time = performance.now() - startTime;
        console.log("error: " + errorMessage);
        return console.log("end_time: " + end_time);
      });
      send_time = performance.now() - startTime;
      console.log("send_time: " + send_time);
    };
  }, false);

}).call(this);