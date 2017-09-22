function toggleImage( ctxName, selectBox) {
  
  if (document.images) {
	theImageSrc = selectBox.options[selectBox.selectedIndex].value;
	
	if (ctxName.length > 0)
		document["userpic"].src = ctxName + theImageSrc;
	else	
		document["userpic"].src = theImageSrc;
  }
}

function toggle(object) {
  if (document.getElementById) {
    if (document.getElementById(object).style.visibility == 'visible'){
      document.getElementById(object).style.visibility = 'hidden';
      document.getElementById(object).style.display = 'none';
    } else{
      document.getElementById(object).style.visibility = 'visible';
	  document.getElementById(object).style.display = 'block';
	}
  }

  else if (document.layers && document.layers[object] != null) {
    if (document.layers[object].visibility == 'visible' ||
        document.layers[object].visibility == 'show' ){
      document.layers[object].visibility = 'hidden';
    }else
      document.layers[object].visibility = 'visible';
  }

  else if (document.all) {
    if (document.all[object].style.visibility == 'visible'){
      document.all[object].style.visibility = 'hidden';
	  document.all[object].style.display = 'none';
    }else{
      document.all[object].style.visibility = 'visible';
	  document.all[object].style.display = 'block';
	}
  }

  return false;
}