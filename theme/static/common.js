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
        switchToVertMobile();
        fancyNotes(false);
    } else if(width > 480 && width < 1200){
        console.log("switch to hor. mobile");
        switchToHorMobile();
        fancyNotes(false);
    } else{
        console.log("switch to desktop");
        switchToDesktop();
        fancyNotes();
    }
}

window.addEventListener('resize', adjustDynamicElements)
window.addEventListener('load', adjustDynamicElements)
