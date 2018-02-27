"use strict";

var codeElementsArray, snippetCount, shortenedSnippetsArray, uncutSnippetsArray;
codeElementsArray = document.getElementsByTagName("CODE");
snippetCount = codeElementsArray.length;
shortenedSnippetsArray = [];
uncutSnippetsArray = [];
processAllSnippets();

function processAllSnippets() {
  var i, snippetDivider;
  for (i=0; i<snippetCount; i++) {

    // Define position of line containing delimiter -- that line will be dividing point for snippet
    snippetDivider = codeElementsArray[i].innerHTML.search(/.*``*./);

    uncutSnippetsArray[i] = codeElementsArray[i].innerHTML;
    if (snippetDivider === -1) {continue;}

    //Create array of processed snippets (shorten them all by the line containing delimiter)
    shortenedSnippetsArray[i] = codeElementsArray[i].innerHTML.slice(0,snippetDivider);

    //Add 'Show more' button to the parent <PRE> element of the <CODE> element containing snippet
    codeElementsArray[i].parentElement.innerHTML += "<button class='collapse_control more collapsed' id='showmoreId" + i + "' onclick='showMore()'>Show more</button>";

    //Render page making all snippets processed
    codeElementsArray[i].innerHTML = shortenedSnippetsArray[i];
  }
}

function showMore() {
  var buttonId, delimiterStart, delimiterEnd, snippetStart, snippetEnd, completeSnippet, buttonContainer;

  //Parent <PRE> element of the <CODE> element. <PRE> contains 'Show more' button, <CODE> contains snippet
  buttonContainer = event.target.parentElement;

  //Extract 'Show more' button id number
  buttonId = event.target.id.slice(10);

  delimiterStart = uncutSnippetsArray[buttonId].indexOf("``");
  snippetStart = uncutSnippetsArray[buttonId].slice(0,delimiterStart);

  //Define position of delimiter end inside snippet (our delimiter is 2 characters long)
  delimiterEnd = delimiterStart + 2;

  snippetEnd = uncutSnippetsArray[buttonId].slice(delimiterEnd);
  completeSnippet = snippetStart + snippetEnd;
  buttonContainer.firstChild.innerHTML = completeSnippet;

  //Change 'Show more' button to 'Show less'
  event.target.outerHTML = "<button class='collapse_control' id='showlessId" + buttonId + "' onclick='showLess()'>Show less</button>";
}

function showLess() {
  var buttonId, snippetDivider, shortenedSnippet, buttonContainer;

  buttonContainer = event.target.parentElement;

  buttonId = event.target.id.slice(10);

  snippetDivider = uncutSnippetsArray[buttonId].search(/.*``*./);

  shortenedSnippet = uncutSnippetsArray[buttonId].slice(0,snippetDivider);

  buttonContainer.firstChild.innerHTML = shortenedSnippet;

  event.target.outerHTML = "<button class='collapse_control more collapsed' id='showmoreId" + buttonId + "' onclick='showMore()'>Show more</button>";
}
