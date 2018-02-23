"use strict";

var snipArr, arrl, visibleArr, wholeArr;
snipArr = document.getElementsByTagName("CODE");
arrl = snipArr.length;
visibleArr = [];
wholeArr = [];
cutAll();

function cutAll() {
  var i, delim;
  for (i=0; i<arrl; i++) {
    delim = snipArr[i].innerHTML.indexOf("&gt;&gt;&gt;showmore");
    wholeArr[i] = snipArr[i].innerHTML;
    if (delim === -1) {continue;}
    visibleArr[i] = snipArr[i].innerHTML.slice(0,delim);
    snipArr[i].parentElement.innerHTML += "<button class='collapse_control more collapsed' id='showmoreId" + i + "' onclick='showMore()'>Show more</button>";
    snipArr[i].innerHTML = visibleArr[i];
  }
}

function showMore() {
  var x, y, z, start, end, whole, parentPre;
  parentPre = event.target.parentElement;
  x = event.target.id.slice(10);
  y = wholeArr[x].indexOf("&gt;&gt;&gt;showmore");
  start = wholeArr[x].slice(0,y);
  z = y + 21;
  end = wholeArr[x].slice(z);
  whole = start + end;
  parentPre.firstChild.innerHTML = whole;
  event.target.outerHTML = "<button class='collapse_control' id='showlessId" + x + "' onclick='showLess()'>Show less</button>";
}

function showLess() {
  var a, pos, complete, parPre;
  parPre = event.target.parentElement;
  a = event.target.id.slice(10);
  pos = wholeArr[a].indexOf("&gt;&gt;&gt;showmore");
  complete = wholeArr[a].slice(0,pos);
  parPre.firstChild.innerHTML = complete;
  event.target.outerHTML = "<button class='collapse_control more collapsed' id='showmoreId" + a + "' onclick='showMore()'>Show more</button>";
}