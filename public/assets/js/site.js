var menuItemClass = ".s-menu__item";

document.addEventListener("DOMContentLoaded", function () {
    document.querySelectorAll(menuItemClass).forEach(function (elm) {
        elm.addEventListener("pointerdown", (event) => {
            elm.classList.add("mousedown");
        });
        elm.addEventListener("pointerup", (event) => {
            elm.classList.remove("mousedown");
        });
        elm.addEventListener("pointercancel", (event) => {
            elm.classList.remove("mousedown");
        });
    })
}, false);