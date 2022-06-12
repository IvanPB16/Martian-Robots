const fs = require('fs');
const compassRose = [{mask: "N", value: 0}, {mask: "E", value: 1}, {mask: "S", value: 2}, {mask: "W", value: 3}]
const lost = [];
function readInstructions(){
  const data = fs.readFileSync('./instrucciones.txt',{encoding:'utf8', flag:'r'});
  return data
}

function processContent(){
  let instruction = readInstructions().split("\n");
  if(instruction.length == 0){
    return "No hay instrucciones."
  }
  let cuadrilla = instruction[0].split(" ");
  let px = parseInt(cuadrilla[0]);
  let py = parseInt(cuadrilla[1]);
  if(validacionXY(px, py)){
    return {
      cuadrilla: {
        x: px,
        y: py,
      },
      instruction: formatInstructions(instruction)
    }
  }else{
    return "The maximum value for any coordinate is 50"
  }
}

function validacionXY(x,y) {
  return (x <= 50 && y <= 50)  
}

function formatInstructions(instructions){
  let datos = instructions.splice(1, instructions.length)
  let count = 0;
  let dataProcess = [];
  while(count < datos.length){
    let ins = {position: '', inst: ''}
    ins.position = datos[count];
    ins.inst = datos[count + 1];
    count= count + 2;
    dataProcess.push(ins)
  }
  return dataProcess;
}

function findValueCompassRose(orientation){
  let results = compassRose.filter(function (objeto) {
    return objeto.mask == orientation;
  });
  let firstObj = results.length > 0 ? results[0] : null;
  if (firstObj == null) return "";
  return firstObj.value;
}

function findMaskCompassRose(value){
  let results = compassRose.filter(function (objeto) {
    return objeto.value == value;
  });
  let firstObj = results.length > 0 ? results[0] : null;
  if (firstObj == null) return "";
  return firstObj.mask;
}

function left(posicion){
  if(posicion.lost) return posicion
  let value = findValueCompassRose(posicion.o);
  let newOrientation = (value == 0)? 3 : value - 1;
  let mask = findMaskCompassRose(newOrientation);
  return {
    x: posicion.x,
    y: posicion.y,
    o: mask,
    lost: posicion.lost
  } 
}

function right(posicion){
  if(posicion.lost) return posicion
  let value = findValueCompassRose(posicion.o);
  let newOrientation = (value == 3)? 0 : value + 1;
  let mask = findMaskCompassRose(newOrientation);
  return {
    x: posicion.x,
    y: posicion.y,
    o: mask,
    lost: posicion.lost
  } 
}

function forward(posicion, cuadrilla){
let lastPosition = posicion
let nuevaPosition = {};
  switch (posicion.o) {
    case 'N':
      nuevaPosition = {...posicion, y: posicion.y + 1};
      break;
    case 'E':
      nuevaPosition = {...posicion, x: posicion.x + 1};
      break;
    case 'S':
      nuevaPosition = {...posicion, y: posicion.y - 1};
      break;
    case 'W':
      nuevaPosition = {...posicion, x: posicion.x - 1};
      break;
  }
  if(lost.length > 0){
    if(validateWithLost(nuevaPosition)){
      return lastPosition;
    }else{
      if(validateGrib(nuevaPosition, cuadrilla)){
        lost.push({...nuevaPosition, lost: true});
        return {...lastPosition, lost: true};
      }else{
        return nuevaPosition;
      }
    }
  }
  if(validateGrib(nuevaPosition, cuadrilla)){
    lost.push({...nuevaPosition, lost: true});
    return {...lastPosition, lost: true};
  }else{
    return nuevaPosition;
  }
}
function validateWithLost(position){
  let results = lost.filter(function (objeto) {
    return objeto.x == position.x && objeto.y == position.y && objeto.o == position.o;
  });
  let firstObj = results.length > 0 ? results[0] : null;
  if (firstObj == null) return false;
  return true;
}

function validateGrib(newPosition, grib){
  return (newPosition.x > grib.x || newPosition.y > grib.y)
}

function formatPositon(posicion){
  let [x, y , o] = posicion.split(' ');
  return { x: parseInt(x), y: parseInt(y), o: o, lost: false}
}
//evaluate the command
function action(comando, posicion, cuadrilla){
  let newPosicion = '';
  switch (comando) {
    case 'R':
      newPosicion = right(posicion);
      break;
    case 'L':
      newPosicion = left(posicion);
      break;
    case 'F':
      newPosicion = forward(posicion, cuadrilla);
      break;
    default:
      break;
  }
  return newPosicion;
}
//run the commands
function doAction(instruciones, posicion, cuadrilla){
  //conversion of commands into an array
  let commans = instruciones.split('');
  let pos = formatPositon(posicion);
  //
  let instances = commans.reduce(function (acc, index, _arr, aarr) {
    //if lost the robot stops the reduce
    if(acc.lost) {
      aarr.splice(0);
    }
    //execute the command action
    return action(index, acc, cuadrilla);
  }, pos)
  return instances;
}

function response(values){
  return values.map(function(x){
    let message = (x.lost)?'LOST': ''
    return `${x.x} ${x.y} ${x.o} ${message}`;
  })
}
//init function
function init(){
  let content = processContent();
  let values = content.instruction.map(function(x) {
    return doAction(x.inst, x.position, content.cuadrilla);
  });
  console.log(response(values));
}


init();