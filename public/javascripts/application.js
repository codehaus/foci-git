// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
var formatBytes = function(elCell, oRecord, oColumn, oData) { 
  var sizes = [ "B", "kB", "MB", "GB", "TB" ];
  
  var bytes = parseFloat(oData);
  var sizeIndex = 0;

  while (bytes > 1.2 * 1024) {
    bytes = bytes / 1024.0;
    sizeIndex = sizeIndex + 1;
  };
  
  var text = bytes.toFixed(1) + sizes[sizeIndex];
  
  elCell.innerHTML = text;
}

var formatResponseTime = function(elCell, oRecord, oColumn, oData) { 
  var time = parseFloat(oData);
  elCell.innerHTML = time.toFixed(2);
}
