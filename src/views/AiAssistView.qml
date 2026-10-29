import QtQuick
import Quickshell
import Quickshell.Io
import "../services"
import "../components"

Item {
  id: root

  property var navStack: null
  property string filterText: ""
  property string queryPrompt: ""
  property bool autoSend: false
  property string preset: ""
  property string responseMarkdown: "Ollama is the default. Ctrl+K → Settings for an OpenAI-compatible endpoint. Keys stay in ~/.config/omnicast/ai.json."
  property bool isGenerating: false
  property bool cancelRequested: false
  property bool gotDelta: false
  property string provider: "ollama"
  property string modelName: ""
  property string endpoint: ""
  property var models: []
  property bool reachable: false
  property bool hasKey: false
  property string openaiBase: "https://api.openai.com/v1"
  property string ollamaUrl: "http://127.0.0.1:11434"
  property int selectedIndex: 0
  property var rows: []
  property bool wideLayout: true

  readonly property bool isBusy: isGenerating
  readonly property string searchPlaceholder: "Ask a question…"
  readonly property string statusHint: {
    var who = provider === "openai" ? "OpenAI-compatible" : "Ollama"
    var model = modelName.length ? modelName : "default model"
    if (isGenerating)
      return who + " · " + model + " · streaming"
    if (!reachable && provider === "ollama")
      return who + " · not reachable"
    return who + " · " + model
  }
  readonly property var selectedItem: rows.length > 0 && selectedIndex < rows.length ? rows[selectedIndex] : null

  signal requestActionPalette(var actions)
  signal requestDismiss()
  signal requestPushViewWithProps(string title, var component, var props)

  property Component formViewComp: Component { FormView {} }

  Process {
    id: statusProc
    command: ["python3", Paths.py("ai_gateway.py"), "status"]
    running: false
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: text => root.applyStatus(text)
    }
  }

  Process {
    id: chatProc
    property string payload: ""
    command: ["python3", Paths.py("ai_gateway.py"), "chat"]
    stdinEnabled: true
    running: false
    onStarted: {
      write(payload + "\n")
      payload = ""
    }
    stdout: SplitParser {
      splitMarker: "\n"
      onRead: line => root.handleChatLine(line)
    }
    onExited: {
      root.isGenerating = false
      root.cancelRequested = false
      root.rebuild()
    }
  }

  Process {
    id: settingsProc
    property string payload: ""
    command: ["python3", Paths.py("ai_gateway.py"), "set"]
    stdinEnabled: true
    running: false
    onStarted: {
      write(payload + "\n")
      payload = ""
    }
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: text => {
        if (root.applyStatus(text))
          Hud.success("AI settings saved")
      }
    }
  }

  function applyStatus(raw) {
    try {
      var data = JSON.parse((raw || "").trim() || "{}")
      if (data.ok === false) {
        Hud.error(data.error || "Could not save AI settings")
        return false
      }
      provider = data.provider || "ollama"
      modelName = data.model || ""
      endpoint = data.endpoint || ""
      models = data.models || []
      reachable = !!data.reachable
      hasKey = !!data.has_key
      if (data.openai_base) openaiBase = data.openai_base
      if (data.ollama_url) ollamaUrl = data.ollama_url
    } catch (e) {
      Hud.error("Could not read AI settings")
      return false
    }
    rebuild()
    return true
  }

  function cancel() {
    if (!chatProc.running)
      return
    cancelRequested = true
    chatProc.running = false
    isGenerating = false
    Hud.info("Cancelled")
    rebuild()
  }

  function beginChat(payload) {
    if (chatProc.running)
      return
    gotDelta = false
    cancelRequested = false
    isGenerating = true
    responseMarkdown = "Asking…"
    chatProc.payload = JSON.stringify(payload)
    chatProc.running = true
    rebuild()
  }

  function sendPrompt(text) {
    var q = String(text || "").trim()
    if (!q.length) {
      Hud.info("Type a question")
      return
    }
    beginChat({ mode: "ask", source: "prompt", prompt: q })
  }

  function sendSource(mode, source) {
    beginChat({ mode: mode, source: source || "clipboard", prompt: "" })
  }

  function handleChatLine(line) {
    var text = String(line || "").trim()
    if (!text.length)
      return
    var msg
    try { msg = JSON.parse(text) } catch (e) { return }
    if (msg.type === "meta") {
      if (msg.model) modelName = msg.model
      if (msg.provider) provider = msg.provider
      rebuild()
      return
    }
    if (msg.type === "delta") {
      if (!gotDelta) {
        responseMarkdown = ""
        gotDelta = true
      }
      responseMarkdown += msg.text || ""
      return
    }
    if (msg.type === "error") {
      isGenerating = false
      var err = msg.error || "AI request failed"
      Hud.error(err)
      if (!gotDelta)
        responseMarkdown = err
      rebuild()
      return
    }
    if (msg.type === "done") {
      isGenerating = false
      if (!gotDelta)
        responseMarkdown = "No response."
      rebuild()
    }
  }

  function cycleModel() {
    if (!models.length) {
      Hud.info(provider === "openai" ? "No models reported" : "Ollama reported no models")
      return
    }
    var i = models.indexOf(modelName)
    var next = models[(i + 1) % models.length]
    settingsProc.payload = JSON.stringify({ model: next })
    settingsProc.running = true
  }

  function openSettings() {
    root.requestPushViewWithProps("AI Settings", root.formViewComp, {
      title: "AI Settings",
      subtitle: "Ollama stays on this machine. A key is only used for an OpenAI-compatible endpoint.",
      fields: [
        { id: "provider", label: "PROVIDER", type: "text", placeholder: "ollama or openai", defaultValue: root.provider },
        { id: "model", label: "MODEL", type: "text", placeholder: "blank uses the first available", defaultValue: root.modelName },
        { id: "ollama_url", label: "OLLAMA URL", type: "text", placeholder: "http://127.0.0.1:11434", defaultValue: root.ollamaUrl },
        { id: "openai_base", label: "OPENAI BASE", type: "text", placeholder: "https://api.openai.com/v1", defaultValue: root.openaiBase },
        { id: "api_key", label: "API KEY", type: "password", placeholder: root.hasKey ? "saved · leave blank to keep" : "optional" }
      ],
      submitHandler: function(values) {
        var patch = {
          provider: values.provider || "ollama",
          model: values.model || "",
          ollama_url: values.ollama_url || "",
          openai_base: values.openai_base || ""
        }
        if (values.api_key && String(values.api_key).length)
          patch.api_key = String(values.api_key)
        settingsProc.payload = JSON.stringify(patch)
        settingsProc.running = true
        Qt.callLater(function() {
          if (root.navStack && root.navStack.depth > 1)
            root.navStack.pop()
        })
      }
    })
  }

  function rebuild() {
    var q = (filterText || "").trim()
    var primary = isGenerating ? "Cancel" : "Ask"
    var next = []
    if (q.length) {
      next.push({
        id: "ask-typed",
        title: "Ask",
        subtitle: q,
        icon: "󰚩",
        badge: "AI",
        primaryActionTitle: primary,
        kind: "ask"
      })
    }
    next.push({
      id: "ai-explain", title: "Explain Clipboard", subtitle: "Send the clipboard, not the query",
      icon: "", badge: "Clip", primaryActionTitle: isGenerating ? "Cancel" : "Explain", kind: "explain"
    })
    next.push({
      id: "ai-summarize", title: "Summarize Clipboard", subtitle: "Short bullets from the clipboard",
      icon: "󰨸", badge: "Clip", primaryActionTitle: isGenerating ? "Cancel" : "Summarize", kind: "summarize"
    })
    next.push({
      id: "ai-grammar", title: "Fix Grammar", subtitle: "Rewrite the clipboard",
      icon: "󰷉", badge: "Clip", primaryActionTitle: isGenerating ? "Cancel" : "Fix", kind: "grammar"
    })
    next.push({
      id: "ai-selection", title: "Explain Selection", subtitle: "Primary selection, else clipboard",
      icon: "󰅺", badge: "Sel", primaryActionTitle: isGenerating ? "Cancel" : "Explain", kind: "selection"
    })
    var prev = selectedIndex
    rows = next
    if (prev >= rows.length)
      selectedIndex = 0
  }

  function runRow(row) {
    if (!row)
      return
    if (isGenerating) {
      cancel()
      return
    }
    if (row.kind === "ask")
      sendPrompt(filterText)
    else if (row.kind === "selection")
      sendSource("explain", "selection")
    else
      sendSource(row.kind, "clipboard")
  }

  function filter(query) {
    filterText = query || ""
    selectedIndex = 0
    rebuild()
  }

  function moveSelection(delta) {
    if (!rows.length) return
    var next = selectedIndex + delta
    if (next < 0) next = rows.length - 1
    if (next >= rows.length) next = 0
    selectedIndex = next
    list.positionViewAtIndex(selectedIndex, ListView.Contain)
  }

  function executeCurrent() {
    if (isGenerating) {
      cancel()
      return
    }
    if (responseMarkdown.length && selectedItem && selectedItem.kind !== "ask" && !(filterText || "").trim().length) {
      runRow(selectedItem)
      return
    }
    runRow(selectedItem)
  }

  function copyResponse() {
    if (!responseMarkdown.length)
      return
    Exec.copyText(responseMarkdown)
    Hud.success("Copied AI response")
  }

  function openActionPalette() {
    var acts = []
    if (isGenerating)
      acts.push({ title: "Cancel", icon: "󰜺", shortcut: "↵", callback: function() { root.cancel() } })
    else if (selectedItem)
      acts.push({ title: selectedItem.primaryActionTitle || "Ask", icon: "󰚩", shortcut: "↵", callback: function() { root.runRow(root.selectedItem) } })
    acts.push({ title: "Copy Response", icon: "", callback: function() { root.copyResponse() } })
    acts.push({ title: "Next Model", icon: "󰒭", callback: function() { root.cycleModel() } })
    acts.push({ title: "Settings", icon: "", callback: function() { root.openSettings() } })
    root.requestActionPalette(acts)
  }

  Row {
    anchors.fill: parent

    ListView {
      id: list
      width: Math.round(parent.width * 0.42)
      height: parent.height
      clip: true
      model: root.rows
      spacing: Theme.rowSpacing
      boundsBehavior: Flickable.StopAtBounds

      delegate: ItemRow {
        width: list.width
        title: modelData.title
        subtitle: modelData.subtitle || ""
        iconText: modelData.icon || ""
        badgeText: modelData.badge || ""
        isSelected: index === root.selectedIndex
        onClicked: root.selectedIndex = index
        onDoubleClicked: { root.selectedIndex = index; root.executeCurrent() }
      }
    }

    Rectangle {
      width: 1
      height: parent.height
      color: Theme.border
    }

    DetailPane {
      width: parent.width - list.width - 1
      height: parent.height
      title: "AI"
      headerBadge: root.isGenerating ? "Streaming" : (root.reachable ? "Ready" : "Offline")
      markdownContent: root.responseMarkdown
      metadata: [
        { label: "Provider", value: root.provider === "openai" ? "OpenAI-compatible" : "Ollama" },
        { label: "Model", value: root.modelName.length ? root.modelName : "auto" },
        { label: "Endpoint", value: root.endpoint || "" }
      ]
    }
  }

  Component.onCompleted: {
    rebuild()
    statusProc.running = true
    if (preset === "explain" || preset === "summarize" || preset === "grammar")
      sendSource(preset, "clipboard")
    else if (preset === "selection")
      sendSource("explain", "selection")
    else if (autoSend && queryPrompt.trim().length)
      sendPrompt(queryPrompt)
  }
}
