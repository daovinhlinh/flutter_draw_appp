const express = require("express");
const socket = require("socket.io");

// App setup
const PORT = process.env.PORT || 3000;
const app = express();
const server = app.listen(PORT, function () {
  console.log(`Listening on port ${PORT}`);
  console.log(`http://localhost:${PORT}`);
  console.log(`ws://localhost:${PORT}`);
});

// Socket setup
const io = socket(server);

const currentSketch = [];

let connected = 0;

io.on("connection", function (socket) {
  connected++;
  console.log("Made socket connection");
  io.emit("allSketches", JSON.stringify(currentSketch));
  // socket.on("connect", () => {

  // });

  socket.on("currentSketch", function (data) {
    // console.log(`currentSketch ${data}`);
    io.emit("currentSketch", `${data}`);
  });

  socket.on("allSketches", function (data) {
    // console.log(`allSketches ${data}`);
    currentSketch.push(data);
    console.log(currentSketch);
    io.emit("allSketches", JSON.stringify(currentSketch));
  });

  //Whenever someone disconnects this piece of code executed
  socket.on("disconnect", function () {
    connected--;
    console.log("A user disconnected");
    if (connected === 0) {
      currentSketch.length = 0;
    }
  });
});
