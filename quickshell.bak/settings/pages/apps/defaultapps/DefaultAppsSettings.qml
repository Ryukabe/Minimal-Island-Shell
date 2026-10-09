// pages/apps/defaultapps/DefaultAppsSettings.qml — Apps > Default apps.
// Real system defaults through xdg-mime (see DefaultAppsService.qml). Needs xdg-utils installed.
import QtQuick
import QtQuick.Layouts
import "../../../components"
import "../../../../services"
import "../../../../styles"
import "."   // DefaultAppsService lives next to this file

PageScroll {
    id: root

    DefaultAppsService { id: svc }

    SectionLabel { text: "Web and mail" }

    GroupCard {
        DropdownRow {
            label: "Web browser"
            options: svc.optionsFor("browser")
            selectedValue: svc.currentName("browser")
            onOptionSelected: (name) => svc.choose("browser", name)
        }

        DropdownRow {
            label: "Email"
            options: svc.optionsFor("email")
            selectedValue: svc.currentName("email")
            onOptionSelected: (name) => svc.choose("email", name)
            showDivider: false
        }
    }

    SectionLabel { text: "Files" }

    GroupCard {
        DropdownRow {
            label: "File manager"
            options: svc.optionsFor("files")
            selectedValue: svc.currentName("files")
            onOptionSelected: (name) => svc.choose("files", name)
            showDivider: false
        }
    }

    SectionLabel { text: "Media" }

    GroupCard {
        DropdownRow {
            label: "Video player"
            options: svc.optionsFor("video")
            selectedValue: svc.currentName("video")
            onOptionSelected: (name) => svc.choose("video", name)
        }

        DropdownRow {
            label: "Music player"
            options: svc.optionsFor("music")
            selectedValue: svc.currentName("music")
            onOptionSelected: (name) => svc.choose("music", name)
        }

        DropdownRow {
            label: "Image viewer"
            options: svc.optionsFor("images")
            selectedValue: svc.currentName("images")
            onOptionSelected: (name) => svc.choose("images", name)
            showDivider: false
        }
    }

    SectionLabel { text: "Documents" }

    GroupCard {
        DropdownRow {
            label: "Text editor"
            options: svc.optionsFor("text")
            selectedValue: svc.currentName("text")
            onOptionSelected: (name) => svc.choose("text", name)
        }

        DropdownRow {
            label: "PDF viewer"
            options: svc.optionsFor("pdf")
            selectedValue: svc.currentName("pdf")
            onOptionSelected: (name) => svc.choose("pdf", name)
            showDivider: false
        }
    }
}
