document.addEventListener("DOMContentLoaded", function () {
    var content = document.querySelector(".content main");
    if (content) {
        var footer = document.createElement("footer");
        footer.style.textAlign = "center";
        footer.style.marginTop = "40px";
        footer.style.paddingTop = "20px";
        footer.style.borderTop = "1px solid #e0e0e0";
        footer.style.color = "#666";
        
        // Change your static text here
        footer.innerHTML = "AI generated text - Use with care - Do your own research.";
        
        content.appendChild(footer);
    }
});
