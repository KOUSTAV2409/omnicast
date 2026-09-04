import QtQuick
import Quickshell
import Quickshell.Io
import "../services"
import "../components"

Item {
  id: root

  property var navStack: null
  property string filterText: ""

  signal requestActionPalette(var actions)
  signal requestDismiss()
  signal requestPushViewWithProps(string title, var component, var props)

  readonly property var selectedItem: listDetail.selectedItem

  property Component formViewComp: Component { FormView {} }

  property Process snippetLoader: Process {
    command: ["python3", Paths.py("snippet_manager.py"), "list"]
    running: false
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: text => root.handleData(text)
    }
  }

  function reloadData() {
    snippetLoader.running = true
  }

  function handleData(raw) {
    try {
      var data = JSON.parse(raw || "[]")
      for (var i = 0; i < data.length; i++) {
        var item = data[i]
        item.primaryActionTitle = "Insert"
        item.action = (function(sid) {
          return function() { root.insertSnippet(sid) }
        })(item.id)

        item.actions = [
          {
            title: "Insert Snippet",
            icon: "⚡",
            shortcut: "↵",
            callback: (function(sid) {
              return function() { root.insertSnippet(sid) }
            })(item.id)
          },
          {
            title: "Copy Snippet",
            icon: "📋",
            shortcut: "Ctrl+C",
            callback: (function(content) {
              return function() { root.copySnippet(content) }
            })(item.content)
          },
          {
            title: "Delete Snippet",
            icon: "🗑️",
            destructive: true,
            callback: (function(sid) {
              return function() { root.deleteSnippet(sid) }
            })(item.id)
          }
        ]
      }

      // Create new entry at top
      data.unshift({
        id: "snip-create",
        title: "Create New Snippet",
        subtitle: "Add a keyword-expandable text template",
        icon: "➕",
        badge: "New",
        primaryActionTitle: "Create",
        markdown: "### Create Snippet\n\nDefine a keyword and template body. Use `{date}`, `{time}`, `{uuid}`, `{clipboard}`.",
        metadata: [],
        action: function() { root.openCreateForm() },
        actions: [
          { title: "Create Snippet", icon: "➕", shortcut: "↵", callback: function() { root.openCreateForm() } }
        ]
      })

      listDetail.items = data
      listDetail.filter(root.filterText)
    } catch (e) {
      console.error("Error parsing snippet JSON:", e)
    }
  }

  function openCreateForm() {
    root.requestPushViewWithProps("New Snippet", root.formViewComp, {
      title: "Create Snippet",
      subtitle: "Keyword expands system-wide when snippet daemon is running.",
      fields: [
        { id: "keyword", label: "KEYWORD", type: "text", placeholder: ":mysnip" },
        { id: "title", label: "TITLE", type: "text", placeholder: "Display name" },
        { id: "snippet", label: "TEMPLATE", type: "text", placeholder: "Hello {date}" },
        { id: "category", label: "CATEGORY", type: "text", placeholder: "General", defaultValue: "General" }
      ],
      onFormSubmitted: function(values) {
        Exec.python("snippet_manager.py", [
          "create",
          values.keyword || "",
          values.title || values.keyword || "Snippet",
          values.snippet || "",
          values.category || "General"
        ])
        Hud.success("Snippet created")
        // Pop happens via nav; reload when returning — dismiss for simplicity
        root.requestDismiss()
      }
    })
  }

  function insertSnippet(sid) {
    Hud.success("Snippet inserted")
    root.requestDismiss()
    Exec.python("snippet_manager.py", ["insert", sid])
  }

  function copySnippet(text) {
    Hud.success("Copied snippet")
    root.requestDismiss()
    Exec.copyText(text || "")
  }

  function deleteSnippet(sid) {
    Exec.python("snippet_manager.py", ["delete", sid])
    Hud.info("Snippet deleted")
    reloadData()
  }

  function filter(query) {
    root.filterText = query
    listDetail.filter(query)
  }

  function moveSelection(delta) {
    listDetail.moveSelection(delta)
  }

  function executeCurrent() {
    listDetail.executeCurrent()
  }

  function openActionPalette() {
    listDetail.openActionPalette()
  }

  ListDetailView {
    id: listDetail
    anchors.fill: parent
    onRequestActionPalette: actions => root.requestActionPalette(actions)
  }

  Component.onCompleted: reloadData()
}
