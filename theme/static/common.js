// Global object to pass common function
var switchToDesktop = function () {};
var switchToHorMobile = function () {};
var switchToVerMobile = function () {};

function fancyNotes(enabled=true){
    var i;
    var value = "note-normal";
    if(enabled){
        value = "";
    }

    var x = document.getElementsByClassName("note-left");
    for (i = 0; i < x.length; i++) {
        x[i].setAttribute('id', value);
    } 
    //lazy
    var y = document.getElementsByClassName("note-right");
    for (i = 0; i < y.length; i++) {
        y[i].setAttribute('id', value);
    } 
}

function adjustDynamicElements(){
    var width = Math.max(document.documentElement.clientWidth, window.innerWidth || 0);

    if(width < 480){
        console.log("switch to vert. mobile");
        // Set images to the full width
        // document.getElementById("gifka").setAttribute("style", "width: 100%;")
        // Disable fancy notes
        fancyNotes(false);
        // Call user function
        switchToVerMobile();
    } else if(width > 480 && width < 1200){
        console.log("switch to hor. mobile");
        // Set images to the almost full width
        // document.getElementById("gifka").setAttribute("style", "width: 80%;")
        // Disable fancy notes
        fancyNotes(false);
        // Call user function
        switchToHorMobile();
    } else{
        console.log("switch to desktop");
        // Set images wide
        // document.getElementById("gifka").setAttribute("style", "max-width: 900px")
        // Enable fancy notes
        fancyNotes();
        // Call user function
        switchToDesktop();
    }
}

window.addEventListener('resize', adjustDynamicElements)
window.addEventListener('load', adjustDynamicElements)
