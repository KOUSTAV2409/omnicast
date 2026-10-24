// Omarchy handoff descriptors (root wires Exec + Ranking + dismiss).
.pragma library

function omarchyHandoffDefs() {
  return [
    { id: "clipboard", title: "Clipboard History", subtitle: "Super+Ctrl+V",
      icon: "", badge: "Omarchy", category: "Omarchy", primary: "Open Clipboard",
      launch: "clipboard" },
    { id: "emoji", title: "Emoji", subtitle: "Super+Ctrl+E",
      icon: "", badge: "Omarchy", category: "Omarchy", primary: "Open Emoji",
      launch: "emoji" },
    { id: "theme", title: "Theme", subtitle: "Switch Omarchy theme",
      icon: "󰸌", badge: "Omarchy", category: "Omarchy", primary: "Open Themes",
      launch: "theme" },
    { id: "background", title: "Background", subtitle: "Wallpaper",
      icon: "", badge: "Omarchy", category: "Omarchy", primary: "Open Backgrounds",
      launch: "background" },
    { id: "images", title: "Images", subtitle: "Browse Pictures",
      icon: "󰋫", badge: "Omarchy", category: "Omarchy", primary: "Open Images",
      launch: "images" },
    { id: "files", title: "Find Files", subtitle: "Type a name here · in:projects · Ctrl+Shift+P",
      icon: "󰈔", badge: "Omarchy", category: "Omarchy", primary: "Open Files",
      launch: "files" },
    { id: "keybindings", title: "Keybindings", subtitle: "Super+K",
      icon: "", badge: "Omarchy", category: "Omarchy", primary: "Open Keybindings",
      launch: "keybindings" },
    { id: "omarchy-menu", title: "Menu", subtitle: "Super+Space",
      icon: "󰣇", badge: "Omarchy", category: "Omarchy", primary: "Open Menu",
      launch: "menu", menuRoute: "root" },
    { id: "capture", title: "Capture", subtitle: "Screenshot & record",
      icon: "", badge: "Omarchy", category: "Omarchy", primary: "Open Capture",
      launch: "menu", menuRoute: "capture" },
    { id: "share", title: "Share", subtitle: "Clipboard, file, folder",
      icon: "", badge: "Omarchy", category: "Omarchy", primary: "Open Share",
      launch: "menu", menuRoute: "share" },
    { id: "reminders", title: "Reminders", subtitle: "Super+Ctrl+R",
      icon: "󰢻", badge: "Omarchy", category: "Omarchy", primary: "Open Reminders",
      launch: "menu", menuRoute: "reminder-set" }
  ]
}
