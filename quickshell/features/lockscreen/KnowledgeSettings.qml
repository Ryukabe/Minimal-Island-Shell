// features/lockscreen/KnowledgeSettings.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    readonly property string _home: Quickshell.env("HOME")
    readonly property string configPath: root._home + "/.config/quickshell/state/knowledge.json"

    property bool _configLoaded: false
    property bool _applyingConfig: false

    // (named slideEnabled because Item already has an "enabled" property)
    property bool slideEnabled: true
    property bool showFacts: true
    property bool showWords: true

    // The entry shown on the lock screen: { id, kind: "fact"|"word", text | word, pos, meaning, example }
    property var current: null
    property string _lastId: ""

    readonly property var facts: [
        "Honey barely spoils. Edible honey has been found in ancient Egyptian tombs.",
        "Octopuses have three hearts.",
        "Botanically, bananas are berries, but strawberries are not.",
        "A day on Venus is longer than its year.",
        "Wombat droppings are cube-shaped.",
        "Sunlight takes about 8 minutes and 20 seconds to reach Earth.",
        "Sharks are older than trees. They have existed for over 400 million years.",
        "The Sundarbans is the largest mangrove forest in the world.",
        "Cox's Bazar in Bangladesh has a beach about 120 km long, often described as the longest natural sea beach in the world.",
        "The Python language is named after Monty Python, not the snake.",
        "The first computer \"bug\" was a real moth, found in a Harvard Mark II in 1947.",
        "An adult human has 206 bones, but a baby is born with around 300.",
        "Lightning can be several times hotter than the surface of the Sun.",
        "Water can boil and freeze at the same time at its triple point.",
        "The Eiffel Tower can grow about 15 cm taller in summer because the iron expands in the heat."
    ]

    readonly property var words: [
        { word: "Ephemeral", pos: "adjective", meaning: "Lasting for a very short time.", example: "The beauty of cherry blossoms is ephemeral." },
        { word: "Serendipity", pos: "noun", meaning: "Finding something good by chance.", example: "Meeting her was pure serendipity." },
        { word: "Ubiquitous", pos: "adjective", meaning: "Present or found everywhere.", example: "Smartphones are ubiquitous today." },
        { word: "Meticulous", pos: "adjective", meaning: "Showing great attention to detail.", example: "She kept meticulous notes for every lecture." },
        { word: "Resilient", pos: "adjective", meaning: "Able to recover quickly from difficulty.", example: "A resilient student learns from a bad result." },
        { word: "Eloquent", pos: "adjective", meaning: "Fluent and persuasive in speaking or writing.", example: "He gave an eloquent speech." },
        { word: "Pragmatic", pos: "adjective", meaning: "Dealing with things in a practical, realistic way.", example: "Take a pragmatic approach to the syllabus." },
        { word: "Ambiguous", pos: "adjective", meaning: "Open to more than one meaning.", example: "The question was ambiguous." },
        { word: "Diligent", pos: "adjective", meaning: "Showing steady, careful effort.", example: "Diligent practice beats occasional bursts." },
        { word: "Lucid", pos: "adjective", meaning: "Clearly expressed and easy to understand.", example: "Her explanation was lucid." },
        { word: "Tenacious", pos: "adjective", meaning: "Holding on firmly; not giving up.", example: "A tenacious learner finishes what they start." },
        { word: "Candid", pos: "adjective", meaning: "Honest and straightforward.", example: "I appreciate your candid feedback." }
    ]

    // Pick a fresh entry. Avoids repeating the previous one.
    function pickNext() {
        var pool = []
        var i
        if (root.showFacts) {
            for (i = 0; i < root.facts.length; i++)
                pool.push({ id: "f" + i, kind: "fact", text: root.facts[i] })
        }
        if (root.showWords) {
            for (i = 0; i < root.words.length; i++) {
                var w = root.words[i]
                pool.push({ id: "w" + i, kind: "word", word: w.word, pos: w.pos,
                            meaning: w.meaning, example: w.example })
            }
        }
        if (pool.length === 0) {
            root.current = null
            return
        }
        var pick = pool[Math.floor(Math.random() * pool.length)]
        if (pool.length > 1) {
            while (pick.id === root._lastId)
                pick = pool[Math.floor(Math.random() * pool.length)]
        }
        root._lastId = pick.id
        root.current = pick
    }

    function _apply(data) {
        root._applyingConfig = true
        if (data.slideEnabled !== undefined) root.slideEnabled = data.slideEnabled;
        if (data.showFacts !== undefined) root.showFacts = data.showFacts;
        if (data.showWords !== undefined) root.showWords = data.showWords;
        root._applyingConfig = false
    }

    FileView {
        id: configFile
        path: root.configPath
        onLoaded: {
            try {
                root._apply(JSON.parse(text()));
            } catch (e) {
                console.log("[KnowledgeSettings] parse error:", e);
            }
            root._configLoaded = true
        }
        onLoadFailed: root._configLoaded = true
    }

    Process { id: saveProcess }

    function save() {
        if (!root._configLoaded || root._applyingConfig) return;
        var data = {
            "slideEnabled": root.slideEnabled,
            "showFacts": root.showFacts,
            "showWords": root.showWords
        };
        saveProcess.command = ["sh", "-c",
            "mkdir -p \"$(dirname \"$2\")\"; printf '%s' \"$1\" > \"$2\"",
            "sh", JSON.stringify(data), root.configPath];
        saveProcess.running = true;
    }

    onSlideEnabledChanged: save()
    onShowFactsChanged: { save(); pickNext() }
    onShowWordsChanged: { save(); pickNext() }
}