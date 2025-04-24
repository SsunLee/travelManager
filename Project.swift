import ProjectDescription

let project = Project(
    name: "travelManager",
    organizationName: "com.sunbae",
    options: .options(
        automaticSchemesOptions: .disabled,
        disableBundleAccessors: false,
        disableShowEnvironmentVarsInScriptPhases: false,
        disableSynthesizedResourceAccessors: false
    ),
    packages: [],
    settings: .settings(
        base: [:],
        configurations: [
            .debug(name: "Debug"),
            .release(name: "Release")
        ],
        defaultSettings: .recommended
    ),
    targets: [
        .target(
            name: "travelManagerApp",
            destinations: [.iPhone],
            product: .app,
            bundleId: "com.sunbae.travelManager",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": [:]
            ]),
            sources: ["Shared/**"],
            resources: [
                "Shared/travelManager.xcdatamodeld",
                "Shared/Assets.xcassets"
            ],
            dependencies: []
        )
    ],
    schemes: [
        .scheme(
            name: "travelManager",
            shared: true,
            buildAction: .buildAction(targets: ["travelManagerApp"]),
            testAction: .targets([]),
            runAction: .runAction(configuration: "Debug"),
            archiveAction: .archiveAction(configuration: "Release"),
            profileAction: .profileAction(configuration: "Release"),
            analyzeAction: .analyzeAction(configuration: "Debug")
        )
    ]
)
