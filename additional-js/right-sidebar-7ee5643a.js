document.addEventListener("DOMContentLoaded", function () {
    var TEXT = "AI generated text - Use with care - Do your own research.";

    var sidebar = document.createElement("aside");
    sidebar.id = "right-sidebar";
    sidebar.style.writingMode = "tb-rl";
    sidebar.style.position = "fixed";
    sidebar.style.top = "0";
    sidebar.style.right = "0";
    sidebar.style.width = "40px";
    sidebar.style.height = "100vh";
    sidebar.style.padding = "100px 16px 50px 16px";
    sidebar.style.boxSizing = "border-box";
    sidebar.style.display = "flex";
    sidebar.style.alignItems = "center";
    sidebar.style.textAlign = "center";
    sidebar.style.borderLeft = "1px solid #e0e0e0";
    sidebar.style.color = "#666";
    sidebar.style.fontSize = "0.85em";
    sidebar.style.lineHeight = "1.5";
    sidebar.style.pointerEvents = "none";

    // Change your static text here
    sidebar.innerHTML = "<div>" + TEXT + "</div>";

    document.body.appendChild(sidebar);

    // Only show the sidebar when the window is wide enough that it won't
    // overlap the page content.
    var mq = window.matchMedia("(min-width: 800px)");
    function apply() {
        sidebar.style.display = mq.matches ? "flex" : "none";
    }
    apply();
    mq.addEventListener("change", apply);
});
